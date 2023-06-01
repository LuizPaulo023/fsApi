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
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlpXYkhLcUtMeGxIVDdNX2lpbHVLVSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iXX0sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvbmFtZSI6ImwudGF2YXJlc0A0aW50ZWxsaWdlbmNlLmNvbS5iciIsImlzcyI6Imh0dHBzOi8vZGV2ZWxvcG1lbnQtNGludGVsbGlnZW5jZS51cy5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NjQyNzFhZGIwMTc4ZjY4MDg3MTFhYWUwIiwiYXVkIjpbIjRjYXN0aHViIiwiaHR0cHM6Ly9kZXZlbG9wbWVudC00aW50ZWxsaWdlbmNlLnVzLmF1dGgwLmNvbS91c2VyaW5mbyJdLCJpYXQiOjE2ODU2MjM3MDYsImV4cCI6MTY4NTcxMDEwNiwiYXpwIjoiUGx4STk0T0dsVFQ1Zk9pYklhQUV0cU05MWh0OVRldFQiLCJzY29wZSI6Im9wZW5pZCBwcm9maWxlIGVtYWlsIiwicGVybWlzc2lvbnMiOlsiY3JlYXRlOnByb2plY3RzIiwiZWRpdDphY2Nlc3MtZ3JvdXBzIiwiZWRpdDppbmRpY2F0b3JzIiwiZWRpdDpteS1ncm91cHMiLCJlZGl0Om9ic2VydmF0aW9ucyIsImVkaXQ6cHJlZGVmaW5lZC1ncm91cHMiLCJlZGl0OnByb2plY3Rpb25zIiwiZWRpdDpzZXJpZXMiLCJyZWFkOmFjY2Vzcy1ncm91cHMiLCJyZWFkOmRvbWFpbnMiLCJyZWFkOmluZGljYXRvcnMiLCJyZWFkOm15LWdyb3VwcyIsInJlYWQ6b2JzZXJ2YXRpb25zIiwicmVhZDpwcmVkZWZpbmVkLWdyb3VwcyIsInJlYWQ6cHJvamVjdGlvbnMiLCJyZWFkOnByb2plY3RzIiwicmVhZDpzZXJpZXMiXX0.t-CN4MISqYxEUroUX-RqbnCIfUMgP_XldSCH1HB4oWPWWjBSpPIjsm8Yr-0i7fB23ls_kxPILAnlX-Qp9eRT2Um5l9_-LMBgHCCWwfOxVskjCwtbTX3UdIregQCozf6IHN8U2qbrG74zh7FGp5uMIBuVDRwreUbZum99OjpPoJP6XWd0eD7f-wuWhWA7HFlHMvSLZ5slW0HLqNRMKAirs1bnaWNzDW0FH-isA1Kj55FBmlC5gcVc7yltLPuE-mNEEiS-5oWhLUK5RL_pavK0v8YgVtVKOQXobvx9wTb9ce_J17BdRe1EuAOKFbvw0DeTsZxpSpTZUT4thy8LJ3CKzQ',
  'Content-Type' = 'application/json'
)

url_dev = 'https://run-4i-dev-4casthub-featurestore-api-mhiml2nixa-ue.a.run.app/'

# Definindo parâmetros do usuário na API - ambiente Stg 

token_stg = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iXX0sImlzcyI6Imh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDYzODdhOGY0OTExYmM1NjgyOTQyNWNmYSIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tL3VzZXJpbmZvIl0sImlhdCI6MTY4NTYyNTI5NywiZXhwIjoxNjg1NzExNjk3LCJhenAiOiJLUW1ldnV3SVFvNVl3S0Zvb0dDVXJVZnNFVWk4eUszNCIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJwZXJtaXNzaW9ucyI6WyJjcmVhdGU6cHJvamVjdHMiLCJlZGl0OmFjY2Vzcy1ncm91cHMiLCJlZGl0OmluZGljYXRvcnMiLCJlZGl0Om15LWdyb3VwcyIsImVkaXQ6b2JzZXJ2YXRpb25zIiwiZWRpdDpwcmVkZWZpbmVkLWdyb3VwcyIsImVkaXQ6cHJvamVjdGlvbnMiLCJlZGl0OnNlcmllcyIsInJlYWQ6YWNjZXNzLWdyb3VwcyIsInJlYWQ6ZG9tYWlucyIsInJlYWQ6aW5kaWNhdG9ycyIsInJlYWQ6bXktZ3JvdXBzIiwicmVhZDpvYnNlcnZhdGlvbnMiLCJyZWFkOnByZWRlZmluZWQtZ3JvdXBzIiwicmVhZDpwcm9qZWN0aW9ucyIsInJlYWQ6cHJvamVjdHMiLCJyZWFkOnNlcmllcyJdfQ.S6RQ368bxb5jwvEttrf6zrSKUc1GrG2MXaCjh1di4aUQBXfxQ81V5tJySso6tGW_UNIE_tfbygFENio5WkHyNDq-6YLtTLe2WuTIn0Hwc4wZiFb7ocM1lzddi5MrkWWSXMA0LQg2XMO5IXmcESKkOiF6figb-TYev7lblXjPRuYyQKmmNM6dPqmYsSh0s4QHwqFsAXqTyUyzt__xVaqebi-N8BpadhLCI49ZVlw7tyde3bkTGD3H38YkpVPCNLcCHe2-2lmgJbDuC1ELRkHV61FQY65lz5IJpow9SGfDP_svT26ogsMVmdSOASKEnioG5CZC7rLOzTKhYSwWs599xw',
  'Content-Type' = 'application/json'
)

url_stg = 'https://run-4i-stg-4casthub-featurestore-api-ht3a3o3bea-ue.a.run.app/api/v1/domains?language=pt-br'

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

