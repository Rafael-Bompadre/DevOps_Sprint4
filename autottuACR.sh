###
### Script para criação do Azure Container Registry (ACR) para o projeto AutoTTU
### Adaptado para CI/CD com Azure Pipelines
###
### Variáveis
###
grupoRecursos=rg-azuredevops-docker
regiao=brazilsouth
nomeACR="autottu"
skuACR=Basic

###
### Criação do Grupo de Recursos
###
# Verifica a existência do grupo de recursos
if [ $(az group exists --name $grupoRecursos) = true ]; then
    echo "O grupo de recursos $grupoRecursos já existe"
else
    # Cria o grupo de recursos
    az group create --name $grupoRecursos --location $regiao
    echo "Grupo de recursos $grupoRecursos criado na localização $regiao"
fi

###
### Criação do Azure Container Registry
###
# Verifica se o ACR já existe
if az acr show --name $nomeACR --resource-group $grupoRecursos &> /dev/null; then
    echo "O ACR $nomeACR já existe"
else
    # Cria o ACR
    az acr create --resource-group $grupoRecursos --name $nomeACR --sku $skuACR
    echo "ACR $nomeACR criado com sucesso"
    # Habilita o Usuário Administrador no Azure Container Registry
    az acr update --name $nomeACR --resource-group $grupoRecursos --admin-enabled true
    echo "Habilitado com sucesso o usuário Administrador para o ACR $nomeACR"
fi

#
# Essa parte do Script só é recomendada para fins de testes e aprendizado
#
# WARNING: [Warning] This output may compromise security by showing secrets. Learn more at: https://go.microsoft.com/fwlink/?linkid=2258669
#
# Recuperar as credenciais do usuário administrador, armazenar em variáveis de ambiente e mostrar as credenciais
ADMIN_USER=$(az acr credential show --name $nomeACR --query "username" -o tsv)
ADMIN_PASSWORD=$(az acr credential show --name $nomeACR --query "passwords[0].value" -o tsv)

# Cria variáveis de ambiente
export ACR_ADMIN_USER=$ADMIN_USER
export ACR_ADMIN_PASSWORD=$ADMIN_PASSWORD

# Mostra as variáveis de ambiente
echo "=========================================="
echo "Credenciais do ACR $nomeACR:"
echo "=========================================="
echo "ACR_ADMIN_USER=$ACR_ADMIN_USER"
echo "ACR_ADMIN_PASSWORD=$ACR_ADMIN_PASSWORD"
echo "=========================================="
echo "IMPORTANTE: Use essas credenciais no Azure DevOps para configurar o Service Connection"
echo "=========================================="

