library(tidyverse)
library(httr)

rm(list = ls())

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
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgyX3VOQkNKVENnU0VNX3Z2TjR2LSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNFZGl0b3IiLCJpczRpIiwiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iLCJpc0JldGEiXSwic2hpbnlwcm94eV9yb2xlcyI6WyJiZG1nIl19LCJpc3MiOiJodHRwczovLzRpbnRlbGxpZ2VuY2UuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDYyMzRjNDI0YTE4ZjM3MDA2OGI3MTFkOSIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNjg4MTI3NjUyLCJleHAiOjE2OTA3MTk2NTIsImF6cCI6Im1TS1pxSDVLcTFXb2N4SmNsbklVUmJWSUtVV1Jqb0p6Iiwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsInBlcm1pc3Npb25zIjpbImNyZWF0ZTpwcm9qZWN0cyIsImVkaXQ6YWNjZXNzLWdyb3VwcyIsImVkaXQ6aW5kaWNhdG9ycyIsImVkaXQ6bXktZ3JvdXBzIiwiZWRpdDpvYnNlcnZhdGlvbnMiLCJlZGl0OnByZWRlZmluZWQtZ3JvdXBzIiwiZWRpdDpwcm9qZWN0aW9ucyIsImVkaXQ6c2VyaWVzIiwicmVhZDphY2Nlc3MtZ3JvdXBzIiwicmVhZDpkb21haW5zIiwicmVhZDppbmRpY2F0b3JzIiwicmVhZDpteS1ncm91cHMiLCJyZWFkOm9ic2VydmF0aW9ucyIsInJlYWQ6cHJlZGVmaW5lZC1ncm91cHMiLCJyZWFkOnByb2plY3Rpb25zIiwicmVhZDpwcm9qZWN0cyIsInJlYWQ6c2VyaWVzIl19.Zv9TGaJLsKwQSa-h0HUxGRfN75i77QD_fpUpsaZTZYWpVOt2aaV4hZGD67tTij3WPcfRZh6OMHN-d6LHyo5l_a-QrMTz4tQXd_vE7_xOT9aQ0XNxQfGmasCc0l7c_9YXj6V6vswnIifLc-SRRVEIFuHuIarOxUANRdLNpakofn1zjUL-LlTe8AefkZ_SQa26LtAHPoACv3OfN21mwYm_Ni_YStsjm8Tahu3fmfKzMfIR7_AS2El_b3OCTV7HNaP9J05jIj_7umgzoK-SoJaEEVFLv5Iy3dUGSf2Adq0bD_T5dPyA6PsnLihfHAtUFEB37sVmnPXXi4CXxgCCR_w0eA',
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

#probls <- readRDS('envio_sids.rds')
# Novas Aberturas ---------------------------------------------------------------------------------------
user = base::getwd() %>%
       stringr::str_extract("^((?:[^/]*/){3})") %>% print()

# user <- 'C:/Users/GabrielBelle/'
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

# problem <- readxl::read_excel(paste0(user, path, 'metadados_migração.xlsx'),
#                               sheet = 'Planilha3') %>% 
#   janitor::clean_names()
# 
# n = n_distinct(problem$sid) %>% print()

metadados_filt <- metadados %>% 
  #Organiza as regioes pro script
  rename(regioes = regioes_4macro) %>% 
  mutate(regioes = str_replace_all(regioes, ' ', ','),
         regioes = str_replace_all(regioes, 'MAX', regioes_depara$max),
         regioes = str_replace_all(regioes, 'UFX', regioes_depara$ufx),
         across(where(is.character), ~gsub('\r','', .x)),
         across(where(is.character), ~gsub('\n','', .x))) %>%
  #Organiza o grupo de transformação
  rename(grupo = grupo_transformacao) %>% 
  #Limpa os indicadores que não serão enviados
  filter(in_fs == F) %>% 
  filter(descontinuada == 'FALSE') %>% 
  filter(is.na(nao_migrar)) %>% 
  filter(str_detect(grupo_4macro, c('Geral'))) %>% 
  #filter(grupo != 'Taxa - 3') %>% 
  #filter(grupo != 'Volume - EN - 2') %>% 
  #filter(crawler == 'sidra_pnad') %>% 
  filter(indicator_code %in% c("MXPUB0072", 
                               "MXBOP0028", 
                               "MXPRC0126"))
  #filter(crawler %in% c("banxico_api"))
  

metadados_filt

sids_dev <- readxl::read_excel(paste0(user, path,
                                      'SERIES_TO_COLLECT_DEV.xlsx')) %>% 
  pluck('serie')
         
#sids_dev %>% glimpse()
# ausentes_fs <- readxl::read_excel(paste0(user, path, 'metadados_migração.xlsx'),
#                               sheet = 'Planilha3') %>% 
#   janitor::clean_names() %>% 
#   mutate(serie = str_sub(a, start = 1, end = 16))%>% pluck("serie")

#i = unique(metadados_filt[1,]$indicator_code)
#154 = EUGDP0099

problems = tibble(sid = c(), status = c())

for (i in unique(metadados_filt$indicator_code)) {
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
  # sids_to_send_metadata <- sids_by_group %>%
  # sids_to_send_metadata <- sids_by_group %>% 
  # filter(str_sub(sid, 16,16) == 'L')
  

  
  sids_to_send_metadata <- sids_by_group %>%
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


