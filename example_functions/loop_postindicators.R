#' @title Script de exemplos com as funções - fsApi
#' @description Busca-se testar as funções do pkg fsApi
#' @author Luiz Paulo Tavares Gonçalves

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
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoiZy5iZWxsZUA0aW50ZWxsaWdlbmNlLmNvbS5iciIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvdXNlcl9tZXRhZGF0YSI6e30sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvYXBwX21ldGFkYXRhIjp7InJvbGVzIjpbImlzRmFhUyIsImlzRmVhdHVyZVN0b3JlIiwiaXNGc0FkbWluIl19LCJpc3MiOiJodHRwczovL2hvbW9sb2dhdGlvbi00aW50ZWxsaWdlbmNlLnVzLmF1dGgwLmNvbS8iLCJzdWIiOiJhdXRoMHw2Mjk4ZjllMzhhZTVjZTAwNjkwNzA2MDIiLCJhdWQiOlsiNGNhc3RodWIiLCJodHRwczovL2hvbW9sb2dhdGlvbi00aW50ZWxsaWdlbmNlLnVzLmF1dGgwLmNvbS91c2VyaW5mbyJdLCJpYXQiOjE2ODcxMjAxNTMsImV4cCI6MTY4NzIwNjU1MywiYXpwIjoiS1FtZXZ1d0lRbzVZd0tGb29HQ1VyVWZzRVVpOHlLMzQiLCJzY29wZSI6Im9wZW5pZCBwcm9maWxlIGVtYWlsIiwicGVybWlzc2lvbnMiOlsiY3JlYXRlOnByb2plY3RzIiwiZWRpdDphY2Nlc3MtZ3JvdXBzIiwiZWRpdDppbmRpY2F0b3JzIiwiZWRpdDpteS1ncm91cHMiLCJlZGl0Om9ic2VydmF0aW9ucyIsImVkaXQ6cHJlZGVmaW5lZC1ncm91cHMiLCJlZGl0OnByb2plY3Rpb25zIiwiZWRpdDpzZXJpZXMiLCJyZWFkOmFjY2Vzcy1ncm91cHMiLCJyZWFkOmRvbWFpbnMiLCJyZWFkOmluZGljYXRvcnMiLCJyZWFkOm15LWdyb3VwcyIsInJlYWQ6b2JzZXJ2YXRpb25zIiwicmVhZDpwcmVkZWZpbmVkLWdyb3VwcyIsInJlYWQ6cHJvamVjdGlvbnMiLCJyZWFkOnByb2plY3RzIiwicmVhZDpzZXJpZXMiXX0.nRVSztZyeGP4wIIocRf5c_wWCalj6jofSBqrmkkrPf11hN4uc-zu7grfUGUf2LUvS2FbDWJMGKoxXQsrGfWPqW2sormNGvPitQdDS6N67ud24AJ9QDKEq4-MYz4BOiaZYMT-DXR0OnEWrFd7An-YzMkgrww70TzktwirQWeyzb1PDhYjg0-kKDI2slpGMknPVsF-_9Vpg3MyWWMoknDhl94DCTntdxrJ-oy2LBOD5orxzonZriURNkgmdBvt9ZZwnH5_lNjHWoBwE_9GlmhPAlhY46rNPCCwLPsmaS21DybD0C5NtUnIu4frtyo7RgN6gRrbWR-jI-XiXnBm02SgVQ',
  'Content-Type' = 'application/json'
)

url_stg = 'https://run-4i-stg-4casthub-featurestore-api-ht3a3o3bea-ue.a.run.app/'

# Definindo parâmetros do usuário na API - ambiente de produção

token_prod = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgyX3VOQkNKVENnU0VNX3Z2TjR2LSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoiZy5iZWxsZUA0aW50ZWxsaWdlbmNlLmNvbS5iciIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvdXNlcl9tZXRhZGF0YSI6e30sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvYXBwX21ldGFkYXRhIjp7InJvbGVzIjpbImlzRWRpdG9yIiwiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iLCJpc0JldGEiXSwic2hpbnlwcm94eV9yb2xlcyI6WyJmYWFzLWludGVybm8iLCJncGEiLCJ2aWF2YXJlam8iLCJhbmJpbWEiXX0sImlzcyI6Imh0dHBzOi8vNGludGVsbGlnZW5jZS5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NjQwMGQ1N2U4NTVjODRjMTkxNGE3NzRkIiwiYXVkIjpbIjRjYXN0aHViIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmF1dGgwLmNvbS91c2VyaW5mbyJdLCJpYXQiOjE2ODY5MzA4OTEsImV4cCI6MTY4OTUyMjg5MSwiYXpwIjoibVNLWnFINUtxMVdvY3hKY2xuSVVSYlZJS1VXUmpvSnoiLCJzY29wZSI6Im9wZW5pZCBwcm9maWxlIGVtYWlsIiwicGVybWlzc2lvbnMiOlsiY3JlYXRlOnByb2plY3RzIiwiZWRpdDphY2Nlc3MtZ3JvdXBzIiwiZWRpdDppbmRpY2F0b3JzIiwiZWRpdDpteS1ncm91cHMiLCJlZGl0Om9ic2VydmF0aW9ucyIsImVkaXQ6cHJlZGVmaW5lZC1ncm91cHMiLCJlZGl0OnByb2plY3Rpb25zIiwiZWRpdDpzZXJpZXMiLCJyZWFkOmFjY2Vzcy1ncm91cHMiLCJyZWFkOmRvbWFpbnMiLCJyZWFkOmluZGljYXRvcnMiLCJyZWFkOm15LWdyb3VwcyIsInJlYWQ6b2JzZXJ2YXRpb25zIiwicmVhZDpwcmVkZWZpbmVkLWdyb3VwcyIsInJlYWQ6cHJvamVjdGlvbnMiLCJyZWFkOnByb2plY3RzIiwicmVhZDpzZXJpZXMiXX0.Y2DVhnLTKkSv75YA3tQdFFWpQxRfOXBfzqK_Q_hDTvD6LkL1y75inPMBWf3MUzQ3OzLWEwj3vhsjHvZI6q9_oqWox2CoDMhZt3T5sa-TMRFQm-BkLTmhZppf-ov6EjHmuRSSKE9zicHlE9rbutfWXTl8JSvKMmoOQA_7iXluGwez99xW_iGP7c5XR1uRjIf2BKtx98I4karcXQ9FL1RN8siGvjdIqZXyVE805BGIa4ouxnQg4HrzZOXSwBPqh1JJNJHAz2H47RS4F3pOV_tbDQS-8LZ2gYHIEVz7cx3rrrHrYnVdJmGWob3MDDn_8yAcCPQ1JRs1s8qCTmePIkeyEg',
  'Content-Type' = 'application/json'
)

url_prod = 'https://run-prod-4casthub-featurestore-api-zdfk3g7cpq-ue.a.run.app/'

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

# Carrega metadados -------------------------------------------------------

user <- 'C:/Users/GabrielBelle/'
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

metadados_filt <- metadados %>% 
  mutate(name_abv_pt_fs = iconv(name_abv_pt_fs,
                                   from="UTF-8",to="ASCII//TRANSLIT")
         ) %>% 
  mutate(across(starts_with('description'), ~str_replace_all(.x, '"',"'"))) %>% 
  filter(in_fs == F) %>%
  filter(descontinuada == 'FALSE') %>%
  filter(is.na(nao_migrar)) %>%
  filter(str_detect(grupo_4macro, c('Geral'))) %>%
  mutate(
    description_pt_fs = ifelse(is.na(description_pt_fs), 
                               'Estamos trabalhando em um texto descritivo deste indicador. Em breve divulgaremos mais detalhes.',
                               description_pt_fs),
    description_en_fs = ifelse(is.na(description_en_fs), 
                               'We are working on a descriptive text about this indicator. We will soon release more details.',
                               description_pt_fs),
  ) %>% 
  filter(sera_migrado == 'TRUE')

# Loop de envio de indicadores ------------------------------------------------------------------------------
problems = tibble(sid = c(), status = c())

for (r in 1:nrow(metadados_filt)) {
  
  print(metadados_filt[r,'indicator_code']$indicator_code)
  
  if (ambiente == 'stg') {
    node_en_send <- str_split(metadados_filt[r, 'tree_en_fs'][[1]],
                              ",")[[1]]
    node_pt_send <- str_split(metadados_filt[r, 'tree_pt_fs'][[1]],
                              ",")[[1]]
  }else if (ambiente == 'prod') {
    node_en_send <- str_split(metadados_filt[r, 'tree_en_fs'][[1]],
                              ",")[[1]][1]
    node_pt_send <- str_split(metadados_filt[r, 'tree_pt_fs'][[1]],
                              ",")[[1]][1]
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
node_en = str_split(metadados_filt[r, 'tree_en_fs'][[1]],
                    ",")[[1]]
node_pt = str_split(metadados_filt[r, 'tree_pt_fs'][[1]],
                    ",")[[1]]
token = token_to_use
url = url_to_use