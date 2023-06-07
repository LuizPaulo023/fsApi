#' @title Exemplo de loop da função de update - Series
#' @author Luiz Paulo T.

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
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlpXYkhLcUtMeGxIVDdNX2lpbHVLVSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iXX0sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvbmFtZSI6ImwudGF2YXJlc0A0aW50ZWxsaWdlbmNlLmNvbS5iciIsImlzcyI6Imh0dHBzOi8vZGV2ZWxvcG1lbnQtNGludGVsbGlnZW5jZS51cy5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NjQyNzFhZGIwMTc4ZjY4MDg3MTFhYWUwIiwiYXVkIjpbIjRjYXN0aHViIiwiaHR0cHM6Ly9kZXZlbG9wbWVudC00aW50ZWxsaWdlbmNlLnVzLmF1dGgwLmNvbS91c2VyaW5mbyJdLCJpYXQiOjE2ODYxMzk5MDksImV4cCI6MTY4NjIyNjMwOSwiYXpwIjoiUGx4STk0T0dsVFQ1Zk9pYklhQUV0cU05MWh0OVRldFQiLCJzY29wZSI6Im9wZW5pZCBwcm9maWxlIGVtYWlsIiwicGVybWlzc2lvbnMiOlsiY3JlYXRlOnByb2plY3RzIiwiZWRpdDphY2Nlc3MtZ3JvdXBzIiwiZWRpdDppbmRpY2F0b3JzIiwiZWRpdDpteS1ncm91cHMiLCJlZGl0Om9ic2VydmF0aW9ucyIsImVkaXQ6cHJlZGVmaW5lZC1ncm91cHMiLCJlZGl0OnByb2plY3Rpb25zIiwiZWRpdDpzZXJpZXMiLCJyZWFkOmFjY2Vzcy1ncm91cHMiLCJyZWFkOmRvbWFpbnMiLCJyZWFkOmluZGljYXRvcnMiLCJyZWFkOm15LWdyb3VwcyIsInJlYWQ6b2JzZXJ2YXRpb25zIiwicmVhZDpwcmVkZWZpbmVkLWdyb3VwcyIsInJlYWQ6cHJvamVjdGlvbnMiLCJyZWFkOnByb2plY3RzIiwicmVhZDpzZXJpZXMiXX0.JkuO8a8z2iyDPIroJwGsAp17V_0Dc1YmJ3U_ZoY3rm7feuKAZ8P811GXJ2GozAuxSculoVEIAwPsJxDypMa_xu_Bq4eZ7NcYHwWZCnkK3rZs57luF03XlJHg5ppHMHAFjJGgMOi2Wr-xJ2FKCwMq2_KkAL2IRJXLsYYRSzgfd8aNWbfCGzvQqo_9zEFdzIiPQtJ6THchLVncK0e0uSqkPNnR7aIn8eJIF-rllFlj5TfYUDAaE3TVc8TIEn7g9fpQ8IRifNeyGgvK2CF-3ypzR8y9nfRwpHLOIQg87gS98B-ZjKZyB-gYbqV4XXHfVA0Ttdz9kYxRa6ShxHY7vgMiJg',
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

ambiente = 'dev' #\ opções: dev, stg, prod

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

# Importando datasets ----------------------------------------------------------

# Metadados 
metadados <- readxl::read_excel(paste0(user, 
                                       path, 
                                       'metadados_migração.xlsx'),
                                skip = 1) %>% janitor::clean_names()


# Grupos de transformação 
grupo_transf <- readxl::read_excel(paste0(user, path,
                                          '/diagrama_grupo_transfs.xlsx'),
                                   sheet = 'depara') %>%
                pivot_longer(cols = everything(),
                             names_to = 'grupo', 
                             values_to = 'transfs') %>%
                arrange(grupo) %>%
                filter(!is.na(transfs))

# Unidade 
depara_unidade <- readxl::read_excel(paste0(user, path,
                                            '/diagrama_grupo_transfs.xlsx'),
                                     sheet = 'depara unidade medida')

# Series - 4macro 
sids_4macro <- readxl::read_excel(paste0(user, path,
                                         '/all_series_4macro.xlsx')) %>%
                      mutate(series_code = str_sub(series_code, 1,13)) %>%
                      distinct(series_code) %>%
                      pluck('series_code')


 regioes_depara <- tibble(
                   max = 'NO1, NE1, SE1, SU1, CO1',
                   ufx = 'RO2, AC2, AM2, RR2, PA2,
                           AP2, TO2, MA2, PI2, CE2, RN2, PB2, PE2, AL2, SE2, BA2,
                           MG2, ES2, RJ2, SP2, PR2, SC2, RS2, MS2, MT2, GO2, DF2')

metadados_filt <- metadados %>% 
  #Organiza as regioes pro script
  rename(regioes = regioes_4macro) %>% 
  mutate(regioes = str_replace_all(regioes, ' ', ','),
         regioes = str_replace_all(regioes, 'MAX', regioes_depara$max),
         regioes = str_replace_all(regioes, 'UFX', regioes_depara$ufx)) %>%
  # Organiza o grupo de transformação
  rename(grupo = grupo_transformacao) %>% 
  #Limpa os indicadores que não serão enviados
  filter(descontinuada == 'FALSE') %>% 
  filter(is.na(nao_migrar)) %>% 
  filter(str_detect(grupo_4macro, c('Geral'))) %>% 
  filter(indicator_code %in% c("ARPRC0114",
                               "BRBOP0044",
                               "BRBOP0014",
                               "BRBOP0010",
                               "BRBOP0005",
                               "BRBOP0002",
                               "BRBOP0001",
                               "BRBOP0006",
                               "BRBOP0003",
                               "BRBOP0011",
                               "BRPUB0021",
                               "BRINR0026",
                               "BRINR0001",
                               "BRPUB0001",
                               "BRBOP0007",
                               "WDPRC0225",
                               "WDPRC0118"
                               ))

metadados_filt %>% nrow()

# Loop indicadores -------------------------------------------------------------
# Obtendo os sids e unidades de medida - parâmetros da função update series 
# Inicializa a variável metadados_update como um data frame vazio
metadados_update <- data.frame()

# Loop sobre os códigos de indicadores únicos
for (i in unique(metadados_filt$indicator_code)) {
  
  df_filt <- metadados_filt %>% dplyr::filter(indicator_code == i)
  # Gera todos os SIDs a partir do Subgrupo
  update <- gen_sids_by_group(indicators_metadado = df_filt,
                              depara_grupos = grupo_transf,
                              depara_unidade = depara_unidade)
  
  # Combina os resultados de cada iteração
  metadados_update <- rbind(metadados_update, update)
  
}

# Aplicando update com a função modify_series 

for (i in 1:nrow(metadados_update)) {
  
  # Chamando a função modificação 
  modify_series(sid = metadados_update$sid[i],
                units_en = metadados_update$un_en[i], 
                units_pt = metadados_update$un_pt[i],
                token = token_to_use,
                url = url_to_use)
  
}


