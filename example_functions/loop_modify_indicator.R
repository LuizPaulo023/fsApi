#' @title Exemplo de loop da função de update indicador
#' @author Luiz Paulo Tavares Gonçalves
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
  'Authorization' = '',
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
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgyX3VOQkNKVENnU0VNX3Z2TjR2LSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoiZy5iZWxsZUA0aW50ZWxsaWdlbmNlLmNvbS5iciIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvdXNlcl9tZXRhZGF0YSI6e30sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvYXBwX21ldGFkYXRhIjp7InJvbGVzIjpbImlzRWRpdG9yIiwiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iLCJpc0JldGEiXSwic2hpbnlwcm94eV9yb2xlcyI6WyJmYWFzLWludGVybm8iLCJncGEiLCJ2aWF2YXJlam8iLCJhbmJpbWEiXX0sImlzcyI6Imh0dHBzOi8vNGludGVsbGlnZW5jZS5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NjQwMGQ1N2U4NTVjODRjMTkxNGE3NzRkIiwiYXVkIjpbIjRjYXN0aHViIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmF1dGgwLmNvbS91c2VyaW5mbyJdLCJpYXQiOjE2ODg0ODM5NjIsImV4cCI6MTY5MTA3NTk2MiwiYXpwIjoibVNLWnFINUtxMVdvY3hKY2xuSVVSYlZJS1VXUmpvSnoiLCJzY29wZSI6Im9wZW5pZCBwcm9maWxlIGVtYWlsIiwicGVybWlzc2lvbnMiOlsiY3JlYXRlOnByb2plY3RzIiwiZWRpdDphY2Nlc3MtZ3JvdXBzIiwiZWRpdDppbmRpY2F0b3JzIiwiZWRpdDpteS1ncm91cHMiLCJlZGl0Om9ic2VydmF0aW9ucyIsImVkaXQ6cHJlZGVmaW5lZC1ncm91cHMiLCJlZGl0OnByb2plY3Rpb25zIiwiZWRpdDpzZXJpZXMiLCJyZWFkOmFjY2Vzcy1ncm91cHMiLCJyZWFkOmRvbWFpbnMiLCJyZWFkOmluZGljYXRvcnMiLCJyZWFkOm15LWdyb3VwcyIsInJlYWQ6b2JzZXJ2YXRpb25zIiwicmVhZDpwcmVkZWZpbmVkLWdyb3VwcyIsInJlYWQ6cHJvamVjdGlvbnMiLCJyZWFkOnByb2plY3RzIiwicmVhZDpzZXJpZXMiXX0.PXLIJPc2b6UKyv8U6zaaJ1s-b5s7L4ax8rzAzDHVZLPT0x_4Ck1CITFIwPWmo7lfEtGNxRgcrDqn8WrmEhS2SUVMpjiqtXNvYMuwCs7kgNKUGOCWgifMmu_QSnO7p8VQd8Q9-xXiJOg-N6gGgCet3h1YThfHhTE6JyaMkWOXHNkVszHNUf8AtBOv9f6fz8VlhNS_WJYSuiJx95LaER5wcDBaWId8zTTdBiPyR-zcgMxsPDMp1bIdJWr_ZNyli_TUMjlMjZYyz3l0EQGfIvGuIRORTQ59mRm1LvP7AiqI0R7MdXSHiwA0vDDfZ7WIuQxzGkTkIB4SMBLFbOSDzTGhpA',
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
  filter(in_fs == F) %>% #\ Presentes na FS
  filter(sera_migrado == 'TRUE') %>% 
  filter(crawler == 'tesouro')

# Loop indicadores -------------------------------------------------------------
  
problem_sids <- tibble(sids = c())

for (r in 1:nrow(metadados_filt)) {

  print(metadados_filt[r,'indicator_code'])
  
  if(metadados_filt[r, 'in_fs']$in_fs) {
    proj = '4intelligence'
  } else {
    proj = ' '
  }

  # Chamando a função modificação
  status <- modify_indicator(
    access_type = "default",
    access_group = "Geral",
    indicator = metadados_filt[r, 'indicator_code'][[1]],
    name_en = metadados_filt[r, 'name_en_fs'][[1]],
    name_pt = metadados_filt[r, 'name_pt_fs'][[1]],
    short_en = metadados_filt[r, 'name_abv_en_fs'][[1]],
    short_pt = metadados_filt[r, 'name_abv_pt_fs'][[1]],
    source_en = metadados_filt[r, 'fonte_fs_en'][[1]],
    source_pt = metadados_filt[r, 'fonte_fs_pt'][[1]],
    description_en =  metadados_filt[r, 'description_en_fs'][[1]],
    description_pt =  metadados_filt[r, 'description_pt_fs'][[1]],
    description_full_en = metadados_filt[r, 'link_metodologia_fs_en'][[1]],
    description_full_pt = metadados_filt[r, 'link_metodologia_fs_pt'][[1]],
    country = str_sub(metadados_filt[r, 'indicator_code'],1,2)[[1]],
    sector = str_sub(metadados_filt[r, 'indicator_code'],3,5)[[1]],
    node_en = str_split(metadados_filt[r, 'tree_en_fs'][[1]],
                        ",")[[1]],
    node_pt = str_split(metadados_filt[r, 'tree_pt_fs'][[1]],
                        ",")[[1]],
    proj_owner = proj,
    token = token_to_use,
    url = url_to_use)
  
  # if(any(status != 200)) {
  #   problem_sids <- problem_sids %>% 
  #     add_row(sids = metadados_filt[r, 'indicator_code'][[1]])
  # }
  
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
description_en =  metadados_filt[r, 'description_en_fs'][[1]]
description_pt =  metadados_filt[r, 'description_pt_fs'][[1]]
description_full_en = metadados_filt[r, 'link_metodologia_fs_en'][[1]]
description_full_pt = metadados_filt[r, 'link_metodologia_fs_pt'][[1]]
country = str_sub(metadados_filt[r, 'indicator_code'],1,2)[[1]]
sector = str_sub(metadados_filt[r, 'indicator_code'],3,5)[[1]]
node_en = str_split(metadados_filt[r, 'tree_en_fs'][[1]],
                    ",")[[1]]
node_pt = str_split(metadados_filt[r, 'tree_pt_fs'][[1]],
                    ",")[[1]]
proj_owner = proj
token = token_to_use
url = url_to_use
