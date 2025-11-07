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
2. Conta OCI e chave API configurada.
3. Preencha um arquivo `terraform.tfvars` (não versionado) com os OCIDs e caminhos.

Exemplo `terraform.tfvars`:
```
tenancy_ocid = "ocid1.tenancy.oc1..xxxxx"
user_ocid = "ocid1.user.oc1..xxxxx"
fingerprint = "ab:cd:ef:gh:..."
private_key_path = "~/.oci/oci_api_key.pem"
region = "sa-saopaulo-1"
compartment_ocid = "ocid1.compartment.oc1..xxxxx"
project_prefix = "prod"
```

Se quiser ajustar tamanho/memória da instância:
```
instance_shape = "VM.Standard.E4.Flex"
instance_ocpus = 1
instance_memory_gbs = 8
```

## Uso
```
terraform init
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```
Para destruir:
```
terraform destroy
```

## Módulo Network
Cria VCN, Internet Gateway, Route Table pública, Security List com portas 22/80/443 e uma subnet pública.

## Módulo Compute
Seleciona a última imagem do SO (Oracle Linux por padrão) e cria uma VM Flex com IP público.

## Execução em CI (GitHub Actions)
Para rodar `terraform plan` e `apply` no GitHub Actions sem commit da chave privada:

1. Cadastre os seguintes Secrets no repositório:
   - `OCI_TENANCY_OCID`
   - `OCI_USER_OCID`
   - `OCI_FINGERPRINT` (fingerprint da chave pública cadastrada na Console OCI)
   - `OCI_PRIVATE_KEY` (conteúdo PEM completo da chave privada, incluindo linhas BEGIN/END)
   - `OCI_REGION`
   - `OCI_COMPARTMENT_OCID`
   - `PROJECT_PREFIX` (ex: prod)
   - `VCN_CIDR` (ex: 10.0.0.0/16)
   - `PUBLIC_SUBNET_CIDR` (ex: 10.0.1.0/24)
   - `INSTANCE_SHAPE` (ex: VM.Standard.E4.Flex)
   - `INSTANCE_OCPUS` (ex: 1)
   - `INSTANCE_MEMORY_GBS` (ex: 8)
   - `IMAGE_OPERATING_SYSTEM` (ex: Oracle Linux)
   - `IMAGE_OPERATING_SYSTEM_VERSION` (ex: 9)
   - `IMAGE_ID` (opcional; deixar vazio para seleção automática)

2. Use o workflow `.github/workflows/terraform.yml` já incluído. Ele faz:
   - Gera arquivo temporário com a chave privada: `echo "${{ secrets.OCI_PRIVATE_KEY }}" > $RUNNER_TEMP/oci_api_key.pem`
   - Exporta `TF_VAR_private_key_path` apontando para esse arquivo efêmero.
   - Executa init/validate/plan e publica artefato do plano.

3. Segurança:
   - Nunca commit o arquivo PEM.
   - Garanta que o secret `OCI_PRIVATE_KEY` não contém espaços extras; copie exatamente do seu arquivo local.
   - Considere habilitar ambiente protegido para o job `apply` (requere aprovação).

4. Caso queira apenas validar em PR sem criar recursos, remova o job `apply` ou adicione condicional `if: github.event_name == 'pull_request'` para pular.

## Troubleshooting

### Erro: can not create client, bad configuration: did not find a proper configuration for private key
Esse erro geralmente significa que o `private_key_path` apontado no seu `terraform.tfvars` não existe ou não é legível.

Checklist:
1. Verifique se o arquivo PEM existe: `secrets/oci_api_key.pem` (ou caminho absoluto).
2. No Windows, use barra normal `/` ou escape `\\` se usar backslashes. Ex: `C:/Users/alexa/projects/oci-iac/secrets/oci_api_key.pem`.
3. Não use interpolação (`${path.module}`) dentro de `terraform.tfvars` – Terraform não expande isso em arquivos `.tfvars`. Use um caminho literal.
4. Confirme permissões do arquivo (no Linux/macOS: `chmod 600`). No Windows, apenas garanta que seu usuário consegue ler.
5. Fingerprint deve corresponder à chave pública cadastrada na OCI: compare o conteúdo de `secrets/oci_api_key_public.pem` com o que foi adicionado na Consola.

Para testar rapidamente:
```
terraform console
> fileexists("secrets/oci_api_key.pem")
```
Se retornar `false`, ajuste o caminho.

Se você preferir variáveis de ambiente, exporte (PowerShell):
```
$env:TF_VAR_private_key_path = "C:/Users/alexa/projects/oci-iac/secrets/oci_api_key.pem"
```
Ou em CMD:
```
set TF_VAR_private_key_path=C:/Users/alexa/projects/oci-iac/secrets/oci_api_key.pem
```

### Erro de validação do private_key_path
Adicionamos uma validação: Terraform falhará cedo se o caminho não existir. Corrija antes de executar `plan`.

## Próximos Passos / Melhorias
- Adicionar módulo de armazenamento (Block Volume)
- Adicionar NSG ao invés de Security List genérica
- Gerenciar chaves SSH para acesso seguro
- Output de OCID da imagem utilizada
