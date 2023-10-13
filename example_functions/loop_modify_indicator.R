#' @title Exemplo de loop da função de update indicador
#' @author Luiz Paulo Tavares Gonçalves
# Dependências/Pkgs

rm(list = ls())

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
  'Authorization' = '',
  'Content-Type' = 'application/json'
)

url_dev = 'https://run-4i-dev-4casthub-featurestore-api-mhiml2nixa-ue.a.run.app/'

# Definindo parâmetros do usuário na API - ambiente Stg

token_stg = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iXX0sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvbmFtZSI6ImwudGF2YXJlc0A0aW50ZWxsaWdlbmNlLmNvbS5iciIsImlzcyI6Imh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDYzODdhOGY0OTExYmM1NjgyOTQyNWNmYSIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tL3VzZXJpbmZvIl0sImlhdCI6MTY5Mjg3OTAzNCwiZXhwIjoxNjkyOTY1NDM0LCJhenAiOiJLUW1ldnV3SVFvNVl3S0Zvb0dDVXJVZnNFVWk4eUszNCIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJwZXJtaXNzaW9ucyI6WyJjcmVhdGU6cHJvamVjdHMiLCJlZGl0OmFjY2Vzcy1ncm91cHMiLCJlZGl0OmluZGljYXRvcnMiLCJlZGl0Om15LWdyb3VwcyIsImVkaXQ6b2JzZXJ2YXRpb25zIiwiZWRpdDpwcmVkZWZpbmVkLWdyb3VwcyIsImVkaXQ6cHJvamVjdGlvbnMiLCJlZGl0OnNlcmllcyIsInJlYWQ6YWNjZXNzLWdyb3VwcyIsInJlYWQ6ZG9tYWlucyIsInJlYWQ6aW5kaWNhdG9ycyIsInJlYWQ6bXktZ3JvdXBzIiwicmVhZDpvYnNlcnZhdGlvbnMiLCJyZWFkOnByZWRlZmluZWQtZ3JvdXBzIiwicmVhZDpwcm9qZWN0aW9ucyIsInJlYWQ6cHJvamVjdHMiLCJyZWFkOnNlcmllcyJdfQ.TouyAaUI__rAGIC6n71WwffFqX4zsnB0sbBFIsKiMH8erkddTkXK7ynMGqrJ7UPSUUcCb7WH7pdkys6FUURe5jR_oJyt5xbg0OUG0nnbkC1vtv12NG0uRkekUAZP_ZT1JK8rPB8o1LT7_nHpw4MiCynGO4xT_CEuwqhDJQaEp1kZrWpaQA1j3w4aUB20wpHc0RB1Pcn8NeNDiPb9zZ07PEt1J9J7to9jW-H5PqTuM4IyJEW9M9fTeehqmplPJQOl-udt5fPtAUBt-WI9mWbQ6stEBVLjbwhEKKwrA54XQezNVVXt5z4DtgzYtzZOcKRBLj4OCv4keBEhW1wqBUFNrw',
  'Content-Type' = 'application/json'
)

url_stg = 'https://apis.4intelligence.ai/api-feature-store-stg/'

# Definindo parâmetros do usuário na API - ambiente de produção

token_prod = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgyX3VOQkNKVENnU0VNX3Z2TjR2LSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNFZGl0b3IiLCJpczRpIiwiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iLCJpc0JldGEiXSwic2hpbnlwcm94eV9yb2xlcyI6WyJiZG1nIl19LCJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL25hbWUiOiJsLnRhdmFyZXNANGludGVsbGlnZW5jZS5jb20uYnIiLCJpc3MiOiJodHRwczovLzRpbnRlbGxpZ2VuY2UuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDYyMzRjNDI0YTE4ZjM3MDA2OGI3MTFkOSIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNjk3MjA3NjQwLCJleHAiOjE2OTk3OTk2NDAsImF6cCI6Im1TS1pxSDVLcTFXb2N4SmNsbklVUmJWSUtVV1Jqb0p6Iiwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsInBlcm1pc3Npb25zIjpbImFzazpxdWVzdGlvbnMiLCJjcmVhdGU6cHJvamVjdHMiLCJlZGl0OmFjY2Vzcy1ncm91cHMiLCJlZGl0OmluZGljYXRvcnMiLCJlZGl0Om15LWdyb3VwcyIsImVkaXQ6b2JzZXJ2YXRpb25zIiwiZWRpdDpwcmVkZWZpbmVkLWdyb3VwcyIsImVkaXQ6cHJvamVjdGlvbnMiLCJlZGl0OnNlcmllcyIsInJlYWQ6YWNjZXNzLWdyb3VwcyIsInJlYWQ6ZG9tYWlucyIsInJlYWQ6aW5kaWNhdG9ycyIsInJlYWQ6bXktZ3JvdXBzIiwicmVhZDpvYnNlcnZhdGlvbnMiLCJyZWFkOnByZWRlZmluZWQtZ3JvdXBzIiwicmVhZDpwcm9qZWN0aW9ucyIsInJlYWQ6cHJvamVjdHMiLCJyZWFkOnNlcmllcyJdfQ.fmIn1FKrY8DEoB9BjYsJN8beBEnl059_8UdXXrer0KtYke9IEDhqwceOOlgBsZdzJLdYbMb1xzDPquJivAAjcbzXDCoCjMDP3RCqE2crHKJSa7rvm76LEiOnaNVrlsl1D6mAg7aJmBSBDRsVaHOzy9i8CYGFZzRbd0_O0_2K42zpZw6nqrkljqF7eRWSfQaVrsg3imsVpbScJCuMejH5oYUlM6jMlsitRtvtOf27cxwGYCzDFP5bj3ldMY1iulMgxphXAVHdpDOPNL2wJf9BD3xY3JFJyThnN5uk69X7IBbZ6w5mK7FHoVgVbE0U2gtiHFFezwUPUdpls1G5ZJ-jsw',
  'Content-Type' = 'application/json'
)

url_prod = 'https://apis.4intelligence.ai/api-feature-store/'

# Definindo o ambiente ---------------------------------------------------------

ambiente = 'prod' #\ opções: dev, stg, prod

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

metadados <- readxl::read_excel("INDICACAO_INEGI.xlsx") %>% 
             janitor::clean_names() %>% 
              dplyr::filter(in_prod_fs == "stg")

# metadados <- readxl::read_excel(paste0(user,
#                                        path,
#                                        'metadados_migração.xlsx'),
#                                 skip = 1) %>%
#              janitor::clean_names()
# 
# sends_poc <- readxl::read_excel("poc_chatGPT_lote.xlsx", sheet = "verificado") %>% 
#               dplyr::filter(sends == "ok") %>% 
#               janitor::clean_names()
# 
# 
# metadados <- dplyr::left_join(sends_poc, metadados, by = "indicator_code")

# Limpando e organizando metadados ---------------------------------------------
# Exemplo retirado do script: loop_postindicators
# Filtros adicionais no final do bloco a seguir
# Filtrando apenas as linhas com link_metodologia, sem NA ou ...

metadados_filt <- metadados %>%
  mutate(
    name_abv_pt_fs = iconv(name_abv_pt_fs,
                           from="UTF-8",to="ASCII//TRANSLIT"),
    description_pt_fs = ifelse(is.na(description_pt_fs),
                               'Estamos trabalhando em um texto descritivo deste indicador. Em breve divulgaremos mais detalhes.',
                               description_pt_fs),
    description_en_fs = ifelse(is.na(description_en_fs),
                               'We are working on a descriptive text about this indicator. We will soon release more details.',
                               description_en_fs),
    across(where(is.character), ~gsub('\r','', .x)),
    across(where(is.character), ~gsub('\n','', .x)),
    across(starts_with('description'), ~str_replace_all(.x, '"',"'"))
  ) %>%
  filter(in_fs == F)  %>% slice(1:10)
#\ Presentes na FS
  # filter(sera_migrado == 'TRUE') %>% 
  # filter(crawler == 'tesouro')


metadados_filt <- metadados


# Loop indicadores -------------------------------------------------------------
  
problem_sids <- tibble(sids = c())

for (r in 1:nrow(metadados_filt)) {

  print(metadados_filt[r,'indicator_code'])
  
  # if(metadados_filt[r, 'in_fs']$in_fs) {
  #   proj = '4intelligence'
  # } else {
  #   proj = ' '
  # }

  # Chamando a função modificação
  status <- post.indicator(access_type = "default",
                           access_group = "Geral",
                           ranking = 1,
                           indicator = metadados_filt[r, 'indicator_code'][[1]],
                           name_en = metadados_filt[r, 'name_en_fs'][[1]],
                           name_pt = metadados_filt[r, 'name_pt_fs'][[1]],
                           short_en = metadados_filt[r, 'name_abv_en_fs'][[1]],
                           short_pt = metadados_filt[r, 'name_abv_pt_fs'][[1]],
                           source_en = metadados_filt[r, 'fonte_fs_en'][[1]],
                           source_pt = metadados_filt[r, 'fonte_fs_pt'][[1]],
                           description_en = metadados_filt[r, 'description_en_fs'][[1]],
                           description_pt = metadados_filt[r, 'description_pt_fs'][[1]],
                           description_full_en = metadados_filt[r, 'link_metodologia_fs_en'][[1]],
                           description_full_pt = metadados_filt[r, 'link_metodologia_fs_pt'][[1]],
                           country = str_sub(metadados_filt[r, 'indicator_code'],1,2)[[1]],
                           sector = str_sub(metadados_filt[r, 'indicator_code'],3,5)[[1]],
                           node_en = str_split(metadados_filt[r, 'tree_en_fs'][[1]],
                                               ",")[[1]],
                           node_pt = str_split(metadados_filt[r, 'tree_pt_fs'][[1]],
                                               ",")[[1]],
                           type_send = 'POST', #ou PUT
                           token = token_to_use,
                           proj_owner = ' ',
                           url = url_to_use)
}
########################################################
access_type = "default"
access_group = "Geral"
indicator = metadados_filt[r, 'indicator_code'][[1]]
name_en = metadados_filt[r, 'name_en_fs'][[1]]
name_pt = metadados_filt[r, 'name_pt_fs'][[1]]
short_en = metadados_filt[r, 'name_abv_en_fs'][[1]]
short_pt = metadados_filt[r, 'name_abv_pt_fs'][[1]]
source_en = metadados_filt[r, 'fonte_fs_en'][[1]]
source_pt = metadados_filt[r, 'fonte_fs_pt'][[1]]
description_en = metadados_filt[r, 'description_en_fs'][[1]]
description_pt = metadados_filt[r, 'description_pt_fs'][[1]]
description_full_en = metadados_filt[r, 'link_metodologia_fs_en'][[1]]
description_full_pt = metadados_filt[r, 'link_metodologia_fs_pt'][[1]]
country = str_sub(metadados_filt[r, 'indicator_code'],1,2)[[1]]
sector = str_sub(metadados_filt[r, 'indicator_code'],3,5)[[1]]
node_en = str_split(metadados_filt[r, 'tree_en_fs'][[1]],
                    ",")[[1]]
node_pt = str_split(metadados_filt[r, 'tree_pt_fs'][[1]],
                    ",")[[1]]
type_send = 'POST' #ou PUT
token = token_to_use
proj_owner = ''
url = url_to_use