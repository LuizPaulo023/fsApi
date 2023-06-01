#' @title Exemplo de loop da função de update 
#' @author Luiz Paulo Tavares Gonçalves

rm(list = ls())

# Dependências/Pkgs

library(tidyverse)
library(stringr)
library(stringi)
library(httr)

# Configurando o caminho/diretório do usuário 

user = base::getwd() %>% 
       stringr::str_extract("^((?:[^/]*/){3})") %>% print()

path <- '4intelligence/Feature Store - Documentos/DRE/Documentação/migracao/'

# Definindo parâmetros do usuário na API - ambiente dev  

token_dev = c(
  'Authorization' = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
  'Content-Type' = 'application/json'
)

url_dev = 'https://run-4i-dev-4casthub-featurestore-api-mhiml2nixa-ue.a.run.app/'

# Definindo parâmetros do usuário na API - ambiente Stg 

token_stg = c(
  'Authorization' = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
  'Content-Type' = 'application/json'
)

url_stg = 'https://run-4i-stg-4casthub-featurestore-api-ht3a3o3bea-ue.a.run.app/'

# Definindo parâmetros do usuário na API - ambiente de produção 

token_prod = c(
  'Authorization' = 'XXXXXXXXXXXXXXXXXXX',
  'Content-Type' = 'application/json'
)

url_prod = ''

# Definindo o ambiente ---------------------------------------------------------

ambiente = 'stg' #\ opções: dev, stg, prod

# Configurando a url e token de acordo com o ambiente escolhido 

if(ambiente == 'dev') {
  
   token_to_use = token_dev
   url_to_use = url_dev
   
} else if (ambiente == 'stg') {
    
   token_to_use = token_stg
   url_to_use = url_stg
   
} else if (ambiente == 'prod') {
  
   token_to_use = token_prod
   url_to_use = url_prod
   
}

# Carrega metadados ------------------------------------------------------------
# Importando dataset com os dados para teste 

metadados <- readxl::read_excel(paste0(user, 
                                       path, 
                                       'metadados_migração.xlsx'),
                                skip = 1) %>%
             janitor::clean_names()


# Limpando e organizando metadados ---------------------------------------------
# Exemplo retirado do script: loop_postindicators 
# Filtros adicionais no final do bloco a seguir 
# Filtrando apenas as linhas com link_metodologia, sem NA ou ... 

metadados_filt <- metadados %>%
                  mutate(across(starts_with('description') | contains('_fs'),
                                ~ifelse(is.na(.x), "...", .x)),
                         name_abv_pt_fs = iconv(name_abv_pt_fs,
                                                from="UTF-8",to="ASCII//TRANSLIT")
                  ) %>%
                  mutate(across(starts_with('description'), ~str_replace_all(.x, '"',"'"))) %>%
                  filter(in_fs == T) %>% #\ Presentes na FS 
                  filter(descontinuada == 'FALSE') %>%
                  filter(is.na(nao_migrar)) %>%
                  filter(str_detect(grupo_4macro, c('Geral'))) %>% 
                  #filter(crawler == 'yahoo_finance')
                  filter(!is.na(link_metodologia_fs)) %>% 
                  filter(link_metodologia_fs != "...")

# Testando a função de modificação individualmente # Sem Loop  -----------------


# ATENÇÃO: DEPENDENTE DAS FUNÇÕES {get.id} & {get.tree}
# Se modify_ind = TRUE, altera o indicador solicitado

# teste_modify = modify_indicator(modify_ind = TRUE,
#                                 indicator = "BRINR0002",
#                                 access_type = "default",
#                                 name_en = "teste",
#                                 name_pt = "TestandoFuncaoEnvioLoop",
#                                 short_en = "teste",
#                                 short_pt = "teste",
#                                 source_en = "teste",
#                                 source_pt = "teste",
#                                 description_en = "teste",
#                                 description_pt = "teste",
#                                 description_full_en = "teste",
#                                 description_full_pt = "teste",
#                                 node_en = "Brazil",
#                                 node_pt = "Brasil",
#                                 token = token_to_use,
#                                 url = url_to_use)

# Loop indicadores -------------------------------------------------------------

for (r in 1:nrow(metadados_filt)) {
  
  print(metadados_filt[r,'indicator_code'])
  
  # Chamando a função modificação 
  modify_indicator(modify_ind = TRUE, 
                   access_type = "default",
                   indicator = metadados_filt[r, 'indicator_code'][[1]], 
                   name_en = metadados_filt[r, 'name_en_fs'][[1]], 
                   name_pt = metadados_filt[r, 'name_pt_fs'][[1]], 
                   short_en = metadados_filt[r, 'name_abv_en_fs'][[1]], 
                   short_pt = metadados_filt[r, 'name_abv_pt_fs'][[1]], 
                   source_en = metadados_filt[r, 'fonte_fs'][[1]], 
                   source_pt = metadados_filt[r, 'fonte_fs'][[1]], 
                   description_en = metadados_filt[r, 'description_en_fs'][[1]], 
                   description_pt = metadados_filt[r, 'description_pt_fs'][[1]], 
                   description_full_en = metadados_filt[r, 'link_metodologia_fs'][[1]], 
                   description_full_pt = metadados_filt[r, 'link_metodologia_fs'][[1]], 
                   node_en = str_split(metadados_filt[r, 'tree_en_fs'][[1]],
                                       ",")[[1]][[1]],
                   node_pt = str_split(metadados_filt[r, 'tree_pt_fs'][[1]],
                                       ",")[[1]][[1]],
                   token = token_to_use,
                   url = url_to_use)
  

  
}

