# OCI Infra (Produção Única)

Infraestrutura enxuta para um ambiente único (produção) na Oracle Cloud Infrastructure usando Terraform.

## Estrutura
```
main.tf        -> Provider, modules e outputs
variables.tf   -> Variáveis de entrada
outputs.tf     -> Reexport de outputs dos módulos
modules/network -> VCN, Subnet pública, IGW, RT, SL
modules/compute -> Instância flex com IP público
```

## Pré-requisitos
1. Terraform >= 1.6
2. Conta OCI e chave API (par de chaves) cadastrada no usuário.
3. Preencha um arquivo `terraform.tfvars` (não versionado) com os OCIDs e parâmetros principais.

Exemplo `terraform.tfvars`:
```
tenancy_ocid = "ocid1.tenancy.oc1..xxxxx"
user_ocid    = "ocid1.user.oc1..xxxxx"
fingerprint  = "ab:cd:ef:gh:..."
private_key  = <<EOF
-----BEGIN PRIVATE KEY-----
...
-----END PRIVATE KEY-----
EOF
region            = "sa-saopaulo-1"
compartment_ocid  = "ocid1.compartment.oc1..xxxxx"
project_prefix    = "prod"
backend_bucket    = "tfstate-meu-prod"          # bucket que armazenará o state
backend_state_key = "terraform/prod/terraform.tfstate"  # caminho dentro do bucket
# object_storage_namespace = "<opcional se workflow já descobrir>"
```
Se preferir, mantenha a chave privada fora do arquivo e injete via variável de ambiente `TF_VAR_private_key`.

### Variáveis de instância (opcionais)
```
instance_shape                 = "VM.Standard.E2.1.Micro"
instance_ocpus                 = 1
instance_memory_gbs            = 8
image_operating_system         = "Oracle Linux"
image_operating_system_version = "9"
```

## Backend (State remoto no OCI Object Storage)
Agora usando backend nativo `oci` (sem S3 compat). No `main.tf`:
```
terraform {
  backend "oci" {}
}
```
Durante o `terraform init`, parâmetros são passados via `-backend-config`:
- bucket: nome do bucket
- namespace: namespace do tenant (se não fornecido, o workflow obtém via CLI)
- region: região OCI
- tenancy_ocid, user_ocid, fingerprint, private_key (ou private_key_path)
- key: caminho relativo dentro do bucket para o state

Exemplo manual (Linux/macOS shell):
```
terraform init \
  -backend-config="bucket=$TF_VAR_backend_bucket" \
  -backend-config="namespace=$(oci os ns get --query 'data' --raw-output)" \
  -backend-config="region=$TF_VAR_region" \
  -backend-config="tenancy_ocid=$TF_VAR_tenancy_ocid" \
  -backend-config="user_ocid=$TF_VAR_user_ocid" \
  -backend-config="fingerprint=$TF_VAR_fingerprint" \
  -backend-config="private_key=$TF_VAR_private_key" \
  -backend-config="key=$TF_VAR_backend_state_key"
```
No Windows (cmd) substitua `$VARS` por `%VARS%`.

## Uso
```
terraform init
terraform plan -out tfplan
terraform apply tfplan
```
Para destruir:
```
terraform destroy
```

## Módulo Network
Cria VCN, Internet Gateway, Route Table pública, Security List com portas 22/80/443 e uma subnet pública.

## Módulo Compute
Seleciona a última imagem do SO (Oracle Linux por padrão) e cria uma VM Flex com IP público. (Comentado por padrão no `main.tf`; descomente para criar.)

## Acesso SSH à Instância
A instância provisionada exige que você forneça uma chave pública via variável `ssh_authorized_keys`.

1. Gere um par de chaves (se ainda não tiver):
   - Linux/macOS:
     ```bash
     ssh-keygen -t ed25519 -C "meu-usuario" -f ~/.ssh/id_ed25519
     ```
   - Windows (PowerShell):
     ```powershell
     ssh-keygen -t ed25519 -C "meu-usuario" -f $env:USERPROFILE\.ssh\id_ed25519
     ```
   - Windows (cmd):
     ```cmd
     ssh-keygen -t ed25519 -C "meu-usuario" -f %USERPROFILE%\.ssh\id_ed25519
     ```

2. Copie o conteúdo da chave pública (`id_ed25519.pub` ou `id_rsa.pub`) e defina em `terraform.tfvars`:
   ```hcl
   ssh_authorized_keys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... usuario"
   ```
   Para múltiplas chaves, coloque-as separadas por `\n` em uma string multi-line:
   ```hcl
   ssh_authorized_keys = <<EOF
   ssh-ed25519 AAAA... usuario1
   ssh-ed25519 AAAA... usuario2
   EOF
   ```

3. Aplique o Terraform.

4. Descubra o IP público (output `instance_public_ip`). Exemplo de conexão (Ubuntu usa usuário `ubuntu`; Oracle Linux usa `opc`):
   - Ubuntu:
     ```bash
     ssh -i ~/.ssh/id_ed25519 ubuntu@$(terraform output -raw instance_public_ip)
     ```
   - Oracle Linux:
     ```bash
     ssh -i ~/.ssh/id_ed25519 opc@$(terraform output -raw instance_public_ip)
     ```
   No Windows (cmd):
   ```cmd
   set IP=%CD%\tmp_ip.txt
   terraform output -raw instance_public_ip > %IP%
   for /f %%i in (%IP%) do ssh -i %USERPROFILE%\.ssh\id_ed25519 ubuntu@%%i
   ```

Se aparecer erro de permissão da chave privada no Windows, ajuste ACL ou gere chave dentro da pasta do usuário.

## Execução em CI (GitHub Actions)
Workflow `.github/workflows/terraform.yml`:
1. Materializa a chave privada em arquivo temporário.
2. Obtém o namespace do Object Storage se não fornecido.
3. Garante a existência do bucket (`oci os bucket get/create`).
4. Executa `terraform init` com backend nativo `oci`.
5. Roda validate/plan e publica artefatos; em branch `main`, aplica usando o plano salvo.

Secrets necessários:
- `OCI_TENANCY_OCID`
- `OCI_USER_OCID`
- `OCI_FINGERPRINT`
- `OCI_PRIVATE_KEY` (conteúdo PEM)
- `OCI_COMPARTMENT_OCID`
- `OCI_REGION`
- `TF_BACKEND_BUCKET`
- `TF_BACKEND_STATE_KEY`
- `SSH_AUTHORIZED_KEYS` (conteúdo da(s) chave(s) pública(s). Para múltiplas, separar por linha.)

Vars (Repository/Environment) opcionais:
- `TF_BACKEND_BUCKET_NAMESPACE` (opcional; se vazio o workflow descobre)

### Injetando ssh_authorized_keys no GitHub Actions
O Terraform consome qualquer variável com prefixo `TF_VAR_`. No workflow definimos:
```
TF_VAR_ssh_authorized_keys: ${{ secrets.SSH_AUTHORIZED_KEYS }}
```
Portanto, basta criar o secret `SSH_AUTHORIZED_KEYS` no repositório com uma ou mais linhas de chaves públicas. Exemplo de valor do secret:
```
ssh-ed25519 AAAA... usuario1
ssh-ed25519 AAAA... usuario2
```
Não inclua espaços extras ou linhas em branco no início/fim.

### Segurança
- Chave privada nunca é persistida além do arquivo temporário no runner (removido ao final).
- Não commit nenhum material sensível.

## Troubleshooting
### Erro de autenticação backend
Verifique fingerprint, usuario e a chave privada.

### Erro: bucket não encontrado / namespace vazio
Confirme permissões e que `oci os ns get` retorna valor.

### Migrando de S3 compat para backend nativo
Se antes usava S3 compat:
1. Faça backup do state.
2. Rode `terraform init -migrate-state` com o novo backend `oci`.

Exemplo:
```
terraform init -migrate-state \
  -backend-config="bucket=..." \
  -backend-config="namespace=..." \
  -backend-config="region=..." \
  -backend-config="tenancy_ocid=..." \
  -backend-config="user_ocid=..." \
  -backend-config="fingerprint=..." \
  -backend-config="private_key=..." \
  -backend-config="key=..."
```

## Próximos Passos / Melhorias
- Adicionar módulo de armazenamento (Block Volume)
- Adicionar NSG ao invés de Security List genérica
- Gerenciar chaves SSH para acesso seguro
- Output de OCID da imagem utilizada
- Avaliar lock remoto (não suportado nativamente no backend OCI; considerar alternativa)
