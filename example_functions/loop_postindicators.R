#' @title Script de exemplos com as funções - fsApi
#' @description Busca-se testar as funções do pkg fsApi
#' @author Luiz Paulo Tavares Gonçalves

rm(list = ls())

library(tidyverse)
library(stringi)
library(httr)


# Definindo parâmetros do usuário - dev  ----------------------------------------------------------
token_dev = c(
  'Authorization' = 'Bearer XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
  'Content-Type' = 'application/json'
)

url_dev = 'https://run-4i-dev-4casthub-featurestore-api-mhiml2nixa-ue.a.run.app/'

# Definindo parâmetros do usuário na API - ambiente Stg

token_stg = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iXX0sImlzcyI6Imh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDYzODdhOGY0OTExYmM1NjgyOTQyNWNmYSIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tL3VzZXJpbmZvIl0sImlhdCI6MTY4NzUyMjQ3MywiZXhwIjoxNjg3NjA4ODczLCJhenAiOiJLUW1ldnV3SVFvNVl3S0Zvb0dDVXJVZnNFVWk4eUszNCIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJwZXJtaXNzaW9ucyI6WyJjcmVhdGU6cHJvamVjdHMiLCJlZGl0OmFjY2Vzcy1ncm91cHMiLCJlZGl0OmluZGljYXRvcnMiLCJlZGl0Om15LWdyb3VwcyIsImVkaXQ6b2JzZXJ2YXRpb25zIiwiZWRpdDpwcmVkZWZpbmVkLWdyb3VwcyIsImVkaXQ6cHJvamVjdGlvbnMiLCJlZGl0OnNlcmllcyIsInJlYWQ6YWNjZXNzLWdyb3VwcyIsInJlYWQ6ZG9tYWlucyIsInJlYWQ6aW5kaWNhdG9ycyIsInJlYWQ6bXktZ3JvdXBzIiwicmVhZDpvYnNlcnZhdGlvbnMiLCJyZWFkOnByZWRlZmluZWQtZ3JvdXBzIiwicmVhZDpwcm9qZWN0aW9ucyIsInJlYWQ6cHJvamVjdHMiLCJyZWFkOnNlcmllcyJdfQ.MJoZDoa9PpKXfq1TQKr09SFEbKeuV7AjTeeJ-ypOcRgMgh-LqsDRjIIhtv8KcHbv_ba2ognTrEnGYYtm02UhbTmdfU1wVr6EzMHLF4Hm0veZ1CMzi6S5cnOU_u8kOlEqRWiSM_YhF4_vfu0zc-sM8wVSZNpHt41x3J3RBL8uirG77b6Jh4Ac2GMEHbrrcIcPLAt5e8naILmbgIbl3czOTokJFU26nLKA0eBL_iPpRB1S_qvyQY4ZlkTPB3Ryb-1QzO8NX2H9pOjMxOhBvia-PyUzBNczG-1R3mWajOeO3EEtXpQ-ImTdaAMlthJRHCBpiJ8o7k66DfRUQS00IVnDaQ',
  'Content-Type' = 'application/json'
)

url_stg = 'https://run-4i-stg-4casthub-featurestore-api-ht3a3o3bea-ue.a.run.app/'

# Definindo parâmetros do usuário na API - ambiente de produção

token_prod = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgyX3VOQkNKVENnU0VNX3Z2TjR2LSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNFZGl0b3IiLCJpczRpIiwiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iLCJpc0JldGEiXSwic2hpbnlwcm94eV9yb2xlcyI6WyJiZG1nIl19LCJpc3MiOiJodHRwczovLzRpbnRlbGxpZ2VuY2UuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDYyMzRjNDI0YTE4ZjM3MDA2OGI3MTFkOSIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNjg4MDQwMjE3LCJleHAiOjE2OTA2MzIyMTcsImF6cCI6Im1TS1pxSDVLcTFXb2N4SmNsbklVUmJWSUtVV1Jqb0p6Iiwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsInBlcm1pc3Npb25zIjpbImNyZWF0ZTpwcm9qZWN0cyIsImVkaXQ6YWNjZXNzLWdyb3VwcyIsImVkaXQ6aW5kaWNhdG9ycyIsImVkaXQ6bXktZ3JvdXBzIiwiZWRpdDpvYnNlcnZhdGlvbnMiLCJlZGl0OnByZWRlZmluZWQtZ3JvdXBzIiwiZWRpdDpwcm9qZWN0aW9ucyIsImVkaXQ6c2VyaWVzIiwicmVhZDphY2Nlc3MtZ3JvdXBzIiwicmVhZDpkb21haW5zIiwicmVhZDppbmRpY2F0b3JzIiwicmVhZDpteS1ncm91cHMiLCJyZWFkOm9ic2VydmF0aW9ucyIsInJlYWQ6cHJlZGVmaW5lZC1ncm91cHMiLCJyZWFkOnByb2plY3Rpb25zIiwicmVhZDpwcm9qZWN0cyIsInJlYWQ6c2VyaWVzIl19.J6pJE3lqyTCiwd_deyYoIMvwTTfyFNLVfqTHHWnfQ7hbliiCuK4Y5Y3aG9uV_WKA0cdbTY5G6yGygJBYdGqXDpWlEOlQmglsLiP_Y5Y6Z_bl5m2p3CFDPm6PBOPuJVSZu5IF4teDHKwxHlcaRji-gALnNRosDADfrsnC_YlMTC5Q00_bmauP-CRYXppAvbxAw6PKb6C9-hsswh7EPhLl934FBRcVHFqCIFpzkAh9WHquvpmR5ke2JZccnTY9X9jMFAIHmeM5XKQeLExwxAPwrmQSr7AFTD94vkM03kQcE8hxPpe_Uu7unTjHffV_JCE6m1tPZHqJ0N3McI8Lsp5-bg',
  'Content-Type' = 'application/json'
)

url_prod = 'https://run-prod-4casthub-featurestore-api-zdfk3g7cpq-ue.a.run.app/'

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

#problm_domingo <- readRDS('problemas_indicadores.rds')
# Carrega metadados -------------------------------------------------------

user = base::getwd() %>%
       stringr::str_extract("^((?:[^/]*/){3})") %>% print()

#user <- 'C:/Users/GabrielBelle/'
path <- '4intelligence/Feature Store - Documentos/DRE/Documentação/migracao/'

metadados <- readxl::read_excel(paste0(user, path, 'metadados_migração.xlsx'),
                                skip = 1) %>% 
  janitor::clean_names()


# a <- tibble(tree = c(metadados$tree_en_fs, metadados$tree_pt_fs)) %>% 
#   mutate(tree = str_split(tree, ', ')) %>% 
#   unnest_wider(tree) %>% 
#   distinct() %>% 
#   rename(
#     a = 1,
#     b = 2,
#     c = 3,
#     d = 4,
#     e = 5, 
#     f = 6,
#     g = 7
#   ) %>% 
#   arrange(a,b,c,d,e,f,g)
# 
# b <- tibble(node = c(a$a, a$b, a$c, a$d, a$e, a$f, a$g)) %>% 
#   distinct() %>% 
#   arrange(node)

# problem <- readxl::read_excel(paste0(user, path, 'metadados_migração.xlsx'),
#                               sheet = 'Planilha3') %>% 
#            janitor::clean_names()
# 
# n = n_distinct(problem$sid) %>% print()

metadados_filt <- metadados %>% 
  mutate(name_abv_pt_fs = iconv(name_abv_pt_fs,
                                   from="UTF-8",to="ASCII//TRANSLIT")
         ) %>% 
  mutate(across(starts_with('description'), ~str_replace_all(.x, '"',"'"))) %>% 
  filter(in_fs == F) %>%
  filter(descontinuada == 'FALSE') %>%
  filter(is.na(nao_migrar)) %>%
  # filter(str_detect(grupo_4macro, c('Geral'))) %>%
  mutate(
    description_pt_fs = ifelse(is.na(description_pt_fs),
                               'Estamos trabalhando em um texto descritivo deste indicador. Em breve divulgaremos mais detalhes.',
                               description_pt_fs),
    description_en_fs = ifelse(is.na(description_en_fs),
                               'We are working on a descriptive text about this indicator. We will soon release more details.',
                              # É description en_fs
                                description_en_fs),
    across(where(is.character), ~gsub('\r','', .x)),
    across(where(is.character), ~gsub('\n','', .x))
  ) %>% 
  #filter(sera_migrado == 'TRUE')  %>% 
  #filter(indicator_code %in% problem$sid) %>% 
  filter(crawler %in% c("banxico_api")) 
  #filter(indicator_code %in% c("BRPUB0023"))

metadados_filt 

# Loop de envio de indicadores ------------------------------------------------------------------------------
problems <- tibble(sid = character(), status = numeric())

for (r in 1:nrow(metadados_filt)) {
  
  print(metadados_filt[r,'indicator_code']$indicator_code)
  
  if (ambiente == 'stg') {
    node_en_send <- str_split(metadados_filt[r, 'tree_en_fs'][[1]],
                              ", ")[[1]]
    node_pt_send <- str_split(metadados_filt[r, 'tree_pt_fs'][[1]],
                              ", ")[[1]]
  }else if (ambiente == 'prod') {
    node_en_send <- str_split(metadados_filt[r, 'tree_en_fs'][[1]],
                              ", ")[[1]][1]
    node_pt_send <- str_split(metadados_filt[r, 'tree_pt_fs'][[1]],
                              ", ")[[1]][1]
  }

  send_indicadores = post.indicator(access_type = "default",
                                    access_group = "Geral",
                                    indicator_code = metadados_filt[r, 'indicator_code'][[1]],
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
                                    node_en = node_en_send,
                                    node_pt = node_pt_send,
                                    token = token_to_use,
                                    url = url_to_use)
  

  
  if (send_indicadores %>% is.null()) {
    print(paste(metadados_filt[r, 'indicator_code'][[1]], '-- já existente'))
  } else if(send_indicadores != 200) {
    problems <- problems %>% 
      add_row(sid = metadados_filt[r, 'indicator_code'][[1]],
              status = send_indicadores)
  } else {
    print(paste(metadados_filt[r, 'indicator_code'][[1]], '-- OK'))
  }
}

access_type = "default"
access_group = "Geral"
indicator_code = metadados_filt[r, 'indicator_code'][[1]]
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
node_en = node_en_send
node_pt = node_pt_send
token = token_to_use
url = url_to_use

