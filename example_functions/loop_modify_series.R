#' @title Exemplo de loop da função de update - Series
#' @author Luiz Paulo T.

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
  'Authorization' = 'Bearer XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
  'Content-Type' = 'application/json'
)

url_dev = 'https://run-4i-dev-4casthub-featurestore-api-mhiml2nixa-ue.a.run.app/'

# Definindo parâmetros do usuário na API - ambiente Stg

token_stg = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoiZy5iZWxsZUA0aW50ZWxsaWdlbmNlLmNvbS5iciIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvdXNlcl9tZXRhZGF0YSI6e30sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvYXBwX21ldGFkYXRhIjp7InJvbGVzIjpbImlzRmFhUyIsImlzRmVhdHVyZVN0b3JlIiwiaXNGc0FkbWluIl19LCJpc3MiOiJodHRwczovL2hvbW9sb2dhdGlvbi00aW50ZWxsaWdlbmNlLnVzLmF1dGgwLmNvbS8iLCJzdWIiOiJhdXRoMHw2Mjk4ZjllMzhhZTVjZTAwNjkwNzA2MDIiLCJhdWQiOlsiNGNhc3RodWIiLCJodHRwczovL2hvbW9sb2dhdGlvbi00aW50ZWxsaWdlbmNlLnVzLmF1dGgwLmNvbS91c2VyaW5mbyJdLCJpYXQiOjE2ODY3NDUxMDksImV4cCI6MTY4NjgzMTUwOSwiYXpwIjoiS1FtZXZ1d0lRbzVZd0tGb29HQ1VyVWZzRVVpOHlLMzQiLCJzY29wZSI6Im9wZW5pZCBwcm9maWxlIGVtYWlsIiwicGVybWlzc2lvbnMiOlsiY3JlYXRlOnByb2plY3RzIiwiZWRpdDphY2Nlc3MtZ3JvdXBzIiwiZWRpdDppbmRpY2F0b3JzIiwiZWRpdDpteS1ncm91cHMiLCJlZGl0Om9ic2VydmF0aW9ucyIsImVkaXQ6cHJlZGVmaW5lZC1ncm91cHMiLCJlZGl0OnByb2plY3Rpb25zIiwiZWRpdDpzZXJpZXMiLCJyZWFkOmFjY2Vzcy1ncm91cHMiLCJyZWFkOmRvbWFpbnMiLCJyZWFkOmluZGljYXRvcnMiLCJyZWFkOm15LWdyb3VwcyIsInJlYWQ6b2JzZXJ2YXRpb25zIiwicmVhZDpwcmVkZWZpbmVkLWdyb3VwcyIsInJlYWQ6cHJvamVjdGlvbnMiLCJyZWFkOnByb2plY3RzIiwicmVhZDpzZXJpZXMiXX0.RQZyauSCTdIJlet8Bcvi_PaAwd16wBFslm077iIOUydWmb4KHD1XEff8sbI_8nxzbijeoIO7Zq4_5f4mLivPyR2fz9u23s4dhIA-7MRrpG8nqwcpH8QUBndWZXD88FAhW7_DATQ-BJq5BkL_Z3T5OSzqwewDWpfT6i-mwrMrQI6T9f4WrN3lCtoouHVyXgDAW28ZhRyubIl1ubLiAvt9ad5cWcGj66FGx_Bu9zcI2dHq3dqvLL2hIsRTatGfBltM9i-K1dcBkeXpsipr5AsWjEpsMuOkliLxL6DiFyVmaGaaXh7Cu5LiqS0gnrE9FEL-MsSqVj0OjQtFjg8cRviEnA',
  'Content-Type' = 'application/json'
)

url_stg = 'https://run-4i-stg-4casthub-featurestore-api-ht3a3o3bea-ue.a.run.app/'

# Definindo parâmetros do usuário na API - ambiente de produção

token_prod = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgyX3VOQkNKVENnU0VNX3Z2TjR2LSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoiZy5iZWxsZUA0aW50ZWxsaWdlbmNlLmNvbS5iciIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvdXNlcl9tZXRhZGF0YSI6e30sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvYXBwX21ldGFkYXRhIjp7InJvbGVzIjpbImlzRWRpdG9yIiwiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iLCJpc0JldGEiXSwic2hpbnlwcm94eV9yb2xlcyI6WyJmYWFzLWludGVybm8iLCJncGEiLCJ2aWF2YXJlam8iLCJhbmJpbWEiXX0sImlzcyI6Imh0dHBzOi8vNGludGVsbGlnZW5jZS5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NjQwMGQ1N2U4NTVjODRjMTkxNGE3NzRkIiwiYXVkIjpbIjRjYXN0aHViIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmF1dGgwLmNvbS91c2VyaW5mbyJdLCJpYXQiOjE2ODY4NTI2OTQsImV4cCI6MTY4OTQ0NDY5NCwiYXpwIjoibVNLWnFINUtxMVdvY3hKY2xuSVVSYlZJS1VXUmpvSnoiLCJzY29wZSI6Im9wZW5pZCBwcm9maWxlIGVtYWlsIiwicGVybWlzc2lvbnMiOlsiY3JlYXRlOnByb2plY3RzIiwiZWRpdDphY2Nlc3MtZ3JvdXBzIiwiZWRpdDppbmRpY2F0b3JzIiwiZWRpdDpteS1ncm91cHMiLCJlZGl0Om9ic2VydmF0aW9ucyIsImVkaXQ6cHJlZGVmaW5lZC1ncm91cHMiLCJlZGl0OnByb2plY3Rpb25zIiwiZWRpdDpzZXJpZXMiLCJyZWFkOmFjY2Vzcy1ncm91cHMiLCJyZWFkOmRvbWFpbnMiLCJyZWFkOmluZGljYXRvcnMiLCJyZWFkOm15LWdyb3VwcyIsInJlYWQ6b2JzZXJ2YXRpb25zIiwicmVhZDpwcmVkZWZpbmVkLWdyb3VwcyIsInJlYWQ6cHJvamVjdGlvbnMiLCJyZWFkOnByb2plY3RzIiwicmVhZDpzZXJpZXMiXX0.WjfSRbDJ-bLqXncelLaIV0Zai7plL43faKcJB_wS61ecQkbwTnAbWOMNGNXwYWMZxAw4WIO8rpGoAycV1Zg2isDxIbMvfA9fMxKbciPaHubBqZ7FIlraewqohHdXYCi8YxGsbrv_PvXCBg3mAUasuE2vGGa4Z_POgzbWOFYPqGDPGKejmg3g7ziKHM_NsT0tN5-c6kp5GMF8M2Zxh-3u8L8S-7Os7t5LVWY8B-jHpKIjh7f1kaKq6Bm8Je8f_sfS26wpYvW9Jd31waMiTUbb8t0a36W9hEIlChs77dJeRyvqQfxAuHWN_Mj8jVvA8U0f1a2WLRt3OAhx8CBW9wLV7A',
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

# Metadados --------------------------------------------------------------------

metadados <- readxl::read_excel(paste0(user,
                                       path,
                                       'metadados_migração.xlsx'),
                                skip = 1) %>% janitor::clean_names()

metadados_filt <- metadados %>% 
  #Limpa os indicadores que não serão editados
  filter(descontinuada == 'FALSE') %>% 
  filter(is.na(nao_migrar)) %>% 
  filter(str_detect(grupo_4macro, c('Geral'))) %>% 
  filter(in_fs) %>% 
  pluck('indicator_code')

# Unidade ----------------------------------------------------------------------

depara_unidade <- readxl::read_excel(paste0(user, path,
                                            '/diagrama_grupo_transfs.xlsx'),
                                     sheet = 'depara unidade medida')

# Chamando a função GET FS-series ----------------------------------------------

sids_in_fs = get_sids(url = url_to_use,
                      token = token_to_use,
                      indicators = metadados_filt) %>%
  dplyr::rename(sids = code)

# Definindo a unidade de medida por SID

metadados_update <- sids_in_fs %>%
  #filter(str_detect(sids, 'ARINR0006')) %>% 
  dplyr::mutate(indicator_code = str_sub(sids, start = 1, end = 9),
                regioes = str_sub(sids, start = 10, end = 12),
                transfs = str_sub(sids, start = 13, end = 16)) %>%
  base::merge(metadados, by = "indicator_code") %>%
  select(indicator_code,
         regioes,
         transfs,
         original_pt,
         original_en,
         real_pt,
         real_en) %>%
  mutate(cod1_cod2 = paste0(str_sub(transfs, 1,1), str_sub(transfs, 4,4))) %>%
  left_join(depara_unidade %>%
            select(cod1_cod2, un_pt, un_en)) %>%
  rowwise() %>%
  mutate(un_pt = ifelse(is.na(un_pt),
                        ifelse(str_sub(cod1_cod2,1,1) %in% c('O', 'S'), original_pt, real_pt),
                        un_pt),
         un_en = ifelse(is.na(un_en),
                        ifelse(str_sub(cod1_cod2,1,1) %in% c('O', 'S'), original_en, real_en),
                        un_en),
         sid = paste0(indicator_code, regioes, transfs)) %>%
  dplyr::ungroup() 

# Loop -------------------------------------------------------------
# Aplicando update com a função modify_series

problem_sids <- tibble(sids = c())

for (i in 1:nrow(metadados_update)) {

  # Chamando a função modificação
  status <- modify_series(sid = metadados_update$sid[i],
                          units_en = metadados_update$un_en[i],
                          units_pt = metadados_update$un_pt[i],
                          token = token_to_use,
                          url = url_to_use)
  
  if(status != 200) {
    problem_sids <- problem_sids %>% 
      add_row(sids = metadados_update$sid[i])
  }

}


