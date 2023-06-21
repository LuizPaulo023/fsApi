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
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoiZy5iZWxsZUA0aW50ZWxsaWdlbmNlLmNvbS5iciIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvdXNlcl9tZXRhZGF0YSI6e30sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvYXBwX21ldGFkYXRhIjp7InJvbGVzIjpbImlzRmFhUyIsImlzRmVhdHVyZVN0b3JlIiwiaXNGc0FkbWluIl19LCJpc3MiOiJodHRwczovL2hvbW9sb2dhdGlvbi00aW50ZWxsaWdlbmNlLnVzLmF1dGgwLmNvbS8iLCJzdWIiOiJhdXRoMHw2Mjk4ZjllMzhhZTVjZTAwNjkwNzA2MDIiLCJhdWQiOlsiNGNhc3RodWIiLCJodHRwczovL2hvbW9sb2dhdGlvbi00aW50ZWxsaWdlbmNlLnVzLmF1dGgwLmNvbS91c2VyaW5mbyJdLCJpYXQiOjE2ODcyNjQyOTEsImV4cCI6MTY4NzM1MDY5MSwiYXpwIjoiS1FtZXZ1d0lRbzVZd0tGb29HQ1VyVWZzRVVpOHlLMzQiLCJzY29wZSI6Im9wZW5pZCBwcm9maWxlIGVtYWlsIiwicGVybWlzc2lvbnMiOlsiY3JlYXRlOnByb2plY3RzIiwiZWRpdDphY2Nlc3MtZ3JvdXBzIiwiZWRpdDppbmRpY2F0b3JzIiwiZWRpdDpteS1ncm91cHMiLCJlZGl0Om9ic2VydmF0aW9ucyIsImVkaXQ6cHJlZGVmaW5lZC1ncm91cHMiLCJlZGl0OnByb2plY3Rpb25zIiwiZWRpdDpzZXJpZXMiLCJyZWFkOmFjY2Vzcy1ncm91cHMiLCJyZWFkOmRvbWFpbnMiLCJyZWFkOmluZGljYXRvcnMiLCJyZWFkOm15LWdyb3VwcyIsInJlYWQ6b2JzZXJ2YXRpb25zIiwicmVhZDpwcmVkZWZpbmVkLWdyb3VwcyIsInJlYWQ6cHJvamVjdGlvbnMiLCJyZWFkOnByb2plY3RzIiwicmVhZDpzZXJpZXMiXX0.mibe5KLPVcUwXD1Uyq0YOswjXMj1eC6-kiivr7kEXEmSKNPC3Jb8bfUy6JZKy1eAsybzdgEgyqzF89N7cryIxa5elt-0KWc6JxmlBocAZaR-BD0IgB39N15s0UhFSQpF36_dNktBdSeYss_YVUnnzsaM0eWhd6dkItN0ug9wFQ3JIRGJNPl-F0EsKyxJdeOSDc4qhCzU4WOObu6py-hWYbucHyQmu01T9-vZRc5RTFHCwDqx33m28ig-JJJJyl_gutd2ZZD3pkTZPsQjdf8hewIQ8OtR3mM4zawqc8YKy3YafdGJ6dV14unU16lp_QTC8iU0GLo9JuCUy0lg8RsDqA',
  'Content-Type' = 'application/json'
)

url_stg = 'https://run-4i-stg-4casthub-featurestore-api-ht3a3o3bea-ue.a.run.app/'

# Definindo parâmetros do usuário na API - ambiente de produção

token_prod = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgyX3VOQkNKVENnU0VNX3Z2TjR2LSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoiZy5iZWxsZUA0aW50ZWxsaWdlbmNlLmNvbS5iciIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvdXNlcl9tZXRhZGF0YSI6e30sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvYXBwX21ldGFkYXRhIjp7InJvbGVzIjpbImlzRWRpdG9yIiwiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iLCJpc0JldGEiXSwic2hpbnlwcm94eV9yb2xlcyI6WyJmYWFzLWludGVybm8iLCJncGEiLCJ2aWF2YXJlam8iLCJhbmJpbWEiXX0sImlzcyI6Imh0dHBzOi8vNGludGVsbGlnZW5jZS5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NjQwMGQ1N2U4NTVjODRjMTkxNGE3NzRkIiwiYXVkIjpbIjRjYXN0aHViIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmF1dGgwLmNvbS91c2VyaW5mbyJdLCJpYXQiOjE2ODcyNjY2MTMsImV4cCI6MTY4OTg1ODYxMywiYXpwIjoibVNLWnFINUtxMVdvY3hKY2xuSVVSYlZJS1VXUmpvSnoiLCJzY29wZSI6Im9wZW5pZCBwcm9maWxlIGVtYWlsIiwicGVybWlzc2lvbnMiOlsiY3JlYXRlOnByb2plY3RzIiwiZWRpdDphY2Nlc3MtZ3JvdXBzIiwiZWRpdDppbmRpY2F0b3JzIiwiZWRpdDpteS1ncm91cHMiLCJlZGl0Om9ic2VydmF0aW9ucyIsImVkaXQ6cHJlZGVmaW5lZC1ncm91cHMiLCJlZGl0OnByb2plY3Rpb25zIiwiZWRpdDpzZXJpZXMiLCJyZWFkOmFjY2Vzcy1ncm91cHMiLCJyZWFkOmRvbWFpbnMiLCJyZWFkOmluZGljYXRvcnMiLCJyZWFkOm15LWdyb3VwcyIsInJlYWQ6b2JzZXJ2YXRpb25zIiwicmVhZDpwcmVkZWZpbmVkLWdyb3VwcyIsInJlYWQ6cHJvamVjdGlvbnMiLCJyZWFkOnByb2plY3RzIiwicmVhZDpzZXJpZXMiXX0.WQBciou31q-TJsaHdCKhaD0b9hLBjI9rGD0zjUxiLDr4GitCkfmAw-Ks_CGQTUMcji5MLMs1KcCSgsXM2DHwDh-Jp_rLNoXdynvUvvxlxJdgFXe9M9Kt4tJtByTvuBuryoJeacjy2JcYTgBEoUX_BBSfpY73vFEfrud4naIOMDU8VFfLElVi4lcvINH_z-rU0vnttZEXO7vvEvYBJ289B2HdpdebRPg6yWvTRroEC8flRm4adwVQXSGkpd4lWT6sVJ_IUSp9cBPZa1DY1USBTXAoU7sUuaiuLGrbt35vxZNMOQkw3_cliRChaaIzx1dmFf1vLgx9DIMZ_o0pfXME6g',
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

problm_domingo <- readRDS('problemas_indicadores.rds')
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

problem <- readxl::read_excel(paste0(user, path, 'metadados_migração.xlsx'),
                              sheet = 'Planilha3') %>% 
  janitor::clean_names()

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
    across(where(is.character), ~gsub('\r','', .x)),
    across(where(is.character), ~gsub('\n','', .x))
  ) %>% 
  #filter(sera_migrado == 'TRUE')  %>% 
  filter(indicator_code %in% problem$sid)

# Loop de envio de indicadores ------------------------------------------------------------------------------
problems = tibble(sid = c(), status = c())

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