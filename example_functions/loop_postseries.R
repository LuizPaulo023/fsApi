library(tidyverse)
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

# Novas Aberturas ---------------------------------------------------------------------------------------

user <- 'C:/Users/GabrielBelle/'
path <- '4intelligence/Feature Store - Documentos/DRE/Documentação/migracao/'

grupo_transf <- readxl::read_excel(paste0(user, path,
                                          '/diagrama_grupo_transfs.xlsx'),
                                   sheet = 'depara') %>%
  pivot_longer(cols = everything(), names_to = 'grupo', values_to = 'transfs') %>%
  arrange(grupo) %>%
  filter(!is.na(transfs))

depara_unidade <- readxl::read_excel(paste0(user, path,
                                            '/diagrama_grupo_transfs.xlsx'),
                                     sheet = 'depara unidade medida')

sids_4macro <- readxl::read_excel(paste0(user, path,
                                         '/all_series_4macro.xlsx')) %>%
  mutate(series_code = str_sub(series_code, 1,13)) %>%
  distinct(series_code) %>%
  pluck('series_code')

metadados <- readxl::read_excel(paste0(user, path, 'metadados_migração.xlsx'),
                                skip = 1) %>% 
  janitor::clean_names()

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
  #Organiza o grupo de transformação
  rename(grupo = grupo_transformacao) %>% 
  #Limpa os indicadores que não serão enviados
  filter(in_fs == F) %>% 
  filter(descontinuada == 'FALSE') %>% 
  filter(is.na(nao_migrar)) %>% 
  filter(str_detect(grupo_4macro, c('Geral'))) %>% 
  filter(grupo != 'Taxa - 3')

sids_dev <- readxl::read_excel(paste0(user, path,
                                      'SERIES_TO_COLLECT_DEV.xlsx')) %>% 
  pluck('serie')
         
#i = unique(metadados_filt[1,]$indicator_code)
#154 = EUGDP0099

problems = tibble(sid = c(), status = c())

for (i in unique(metadados_filt$indicator_code)[19:1000]) {
  df_filt <- metadados_filt %>%
    filter(indicator_code == i)

  #Gera todos os SIDs a partir do Subgrupo
  sids_by_group <- gen_sids_by_group(indicators_metadado = df_filt,
                                     depara_grupos = grupo_transf,
                                     depara_unidade = depara_unidade)

  # #Mantem apenas os SIDs com a combinação de região+transf_primaria
  # #Previamente existente no 4macro (e ativo)
  # sids_sub13 <- str_sub(sids_by_group$sid, 1, 13)
  # sids_to_send <- sids_by_group$sid[sids_sub13 %in% sids_4macro]
  # 
  # sids_to_send_metadata <- sids_by_group %>% 
  #   #filter(str_sub(sid, 13,13) == 'O')
  #   filter(sid %in% sids_to_send)
  
  # Mantem apenas os SIDs criados e validados em dev
  sids_to_send_metadata <- sids_by_group %>% 
    #filter(str_sub(sid, 13,13) == 'O')
    filter(sid %in% sids_dev)
  
  print(paste0("Enviando as aberturas para o indicador: ", i))

  if(sids_to_send_metadata %>% nrow() != 0){

   post_sid =  post_series(indicators_metadado = sids_to_send_metadata,
                          token = token_to_use,
                          url = url_to_use)
  } else {
    F
  }
  
  if(!is.null(post_sid)) {
    problems = problems %>% 
      bind_rows(post_sid)
  }

  del_sids <- select_sids_to_del(indicator = i,
                                 new_sids = sids_to_send_metadata,
                                 token = token_to_use,
                                 url = url_to_use)

  if(!identical(del_sids, character(0))) {
    print(paste0("Deletando aberturas indesejadas do indicador: ", i))
    delete_series(indicator = i,
                  del_series = del_sids,
                  token = token_to_use,
                  url = url_to_use)
    stop()
  } else {
    print(paste0("Sem aberturas para excluir para o indicador ", i))
  }
  
  Sys.sleep(0.5)
}


