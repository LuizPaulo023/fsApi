# install.packages("devtools")
# devtools::install_github("LuizPaulo023/fsApi", ref = "main")
# rm(list = ls())
#library(fsApi)

library(tidyverse)
library(httr)

# Definindo parâmetros do usuário - dev  ----------------------------------------------------------

token_dev = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlpXYkhLcUtMeGxIVDdNX2lpbHVLVSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoiZy5iZWxsZUA0aW50ZWxsaWdlbmNlLmNvbS5iciIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvdXNlcl9tZXRhZGF0YSI6e30sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvYXBwX21ldGFkYXRhIjp7InJvbGVzIjpbImlzRWRpdG9yIiwiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iLCJpc0JldGEiXX0sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvbmFtZSI6ImcuYmVsbGVANGludGVsbGlnZW5jZS5jb20uYnIiLCJpc3MiOiJodHRwczovL2RldmVsb3BtZW50LTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDY0MDI0MDFiZTUxZjM0YWQ1OWFlNmVhNCIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vZGV2ZWxvcG1lbnQtNGludGVsbGlnZW5jZS51cy5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNjgwNTI5MzYzLCJleHAiOjE2ODA2MTU3NjMsImF6cCI6IlBseEk5NE9HbFRUNWZPaWJJYUFFdHFNOTFodDlUZXRUIiwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsInBlcm1pc3Npb25zIjpbImNyZWF0ZTpwcm9qZWN0cyIsImVkaXQ6YWNjZXNzLWdyb3VwcyIsImVkaXQ6aW5kaWNhdG9ycyIsImVkaXQ6bXktZ3JvdXBzIiwiZWRpdDpvYnNlcnZhdGlvbnMiLCJlZGl0OnByZWRlZmluZWQtZ3JvdXBzIiwiZWRpdDpwcm9qZWN0aW9ucyIsImVkaXQ6c2VyaWVzIiwicmVhZDphY2Nlc3MtZ3JvdXBzIiwicmVhZDpkb21haW5zIiwicmVhZDppbmRpY2F0b3JzIiwicmVhZDpteS1ncm91cHMiLCJyZWFkOm9ic2VydmF0aW9ucyIsInJlYWQ6cHJlZGVmaW5lZC1ncm91cHMiLCJyZWFkOnByb2plY3Rpb25zIiwicmVhZDpwcm9qZWN0cyIsInJlYWQ6c2VyaWVzIl19.rvII03XOg7SZaUc0aFg1qISZK8I0ME1TbXbQDTgPKAtjkp1BHRKGHl9N5I5Vz8Um8u0uPfJSTJiQwzlxUt5IRFKP3RQNie-rH-XTMN0Uyr-OpH0RMfYQmKxKGrdO2etSnY7CCZg57eSEIPVyM2_DH5r-dAbIxvDtmcvWP9S2c57Mk6drH3gUP0DX-k2CfCoEzuDHty7tvizGt0XdwPOyZ6K4GpkNs2jXPkKhD52NhD7cd1ShkXU2F8TZJEedCx8u4ECyCIaWbDOxgjW7C26ivJAtHyFX5envAMDbcTaocgA52z9dPN4jNuN9mdwjh5oPQ0_36uLSC0-FTxa1-bYvfg',
  'Content-Type' = 'application/json'
)

url_dev = 'https://run-4i-dev-4casthub-featurestore-api-mhiml2nixa-ue.a.run.app/'

# Definindo o Token do usuário - homologação ----------------------------------------------------------

token_hmg = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iXX0sImlzcyI6Imh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDYzODdhOGY0OTExYmM1NjgyOTQyNWNmYSIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tL3VzZXJpbmZvIl0sImlhdCI6MTY4MDU0NDc1NCwiZXhwIjoxNjgwNjMxMTU0LCJhenAiOiJLUW1ldnV3SVFvNVl3S0Zvb0dDVXJVZnNFVWk4eUszNCIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJwZXJtaXNzaW9ucyI6WyJjcmVhdGU6cHJvamVjdHMiLCJlZGl0OmFjY2Vzcy1ncm91cHMiLCJlZGl0OmluZGljYXRvcnMiLCJlZGl0Om15LWdyb3VwcyIsImVkaXQ6b2JzZXJ2YXRpb25zIiwiZWRpdDpwcmVkZWZpbmVkLWdyb3VwcyIsImVkaXQ6cHJvamVjdGlvbnMiLCJlZGl0OnNlcmllcyIsInJlYWQ6YWNjZXNzLWdyb3VwcyIsInJlYWQ6ZG9tYWlucyIsInJlYWQ6aW5kaWNhdG9ycyIsInJlYWQ6bXktZ3JvdXBzIiwicmVhZDpvYnNlcnZhdGlvbnMiLCJyZWFkOnByZWRlZmluZWQtZ3JvdXBzIiwicmVhZDpwcm9qZWN0aW9ucyIsInJlYWQ6cHJvamVjdHMiLCJyZWFkOnNlcmllcyJdfQ.xGvwMVqErXUCFCKntl6OxJ9AeskVDk5D7l2A4Jkl3yfBfdV0busM7s__h-OZDanzXSz3I_jwlXqHJDWkZ0tVjD1qLeXh_ykVDPCfOzvi92Qxjnk3v3aBexFiCnoCZ4vlc-_7cecBCNgaMdc0s1CgeF8KWnl5JN_kY2QF4ISrM-SjGi52ihjRS-HEs25Sca8RfiMB8d4tXNk1Lehy2dXtewnbYFa7uM_Ejo9rguLzYAby6E2yoRM5RJpmN8j8a81VoZdB9-RFyYXGcYUu1Aih52vD2a9wnX6KlXkgv-Dc0PW5LL7v6ybimQ52JMfffNZBmtDSH74hRN0GzPolpMMZVw',
  'Content-Type' = 'application/json'
)

url_hmg = 'https://4i-featurestore-hmg-api-pt.azurewebsites.net/'


# Definindo o Token do usuário - produção --------------------------------------------------------------------------

token_prod = c(
  'Authorization' = 'Bearer INSIRA O TOKEN DE ACESSO',
  'Content-Type' = 'application/json'
)

url_prod = 'https://run-prod-4casthub-featurestore-api-zdfk3g7cpq-ue.a.run.app/'

# Novas Aberturas ---------------------------------------------------------------------------------------

belle_path <- 'C:/Users/GabrielBelle/4intelligence/Feature Store - Documentos/DRE/Documentação/migracao'

indicators_metadado <- readxl::read_excel(paste0(belle_path,
                                            '/grupos_transfs_FS.xlsx')) %>%
  select(codigo, grupo, subgrupo, rg, starts_with('original_'), starts_with('real_')) %>%
  mutate(grupo = paste0(grupo, ' - ', subgrupo)) %>%
  rename(regioes = rg) %>%
  filter(startsWith(grupo, 'Taxa') |
           startsWith(grupo, 'Volume - FN')) %>%
  #filter(startsWith(codigo, 'BRMTG')) %>%
  filter(grupo != 'NA - NA')


grupo_transf <- readxl::read_excel(paste0(belle_path,
                                          '/diagrama_grupo_transfs.xlsx'),
                                   sheet = 'depara') %>%
  pivot_longer(cols = everything(), names_to = 'grupo', values_to = 'transfs') %>%
  arrange(grupo) %>%
  filter(!is.na(transfs))

depara_unidade <- readxl::read_excel(paste0(belle_path,
                                            '/diagrama_grupo_transfs.xlsx'),
                                     sheet = 'depara unidade medida')

sids_4macro <- readxl::read_excel(paste0(belle_path,
                                         '/all_series_4macro.xlsx')) %>%
  mutate(series_code = str_sub(series_code, 1,13)) %>%
  distinct(series_code) %>%
  pluck('series_code')

#Problemas:
# Excluir apenas o SID errado, evitando desabilitar indicador
# Subir apenas transf primaria que ja existe no 4macro, de acordo com a região

#i = unique(indicators_metadado[69,]$codigo)

for (i in unique(indicators_metadado$codigo)) {
  df_filt <- indicators_metadado %>%
    filter(codigo == i)

  #Gera todos os SIDs a partir do Subgrupo
  sids_by_group <- gen_sids_by_group(indicators_metadado = df_filt,
                                     depara_grupos = grupo_transf,
                                     depara_unidade = depara_unidade)

  #Mantem apenas os SIDs com a combinação de região+transf_primaria
  #Previamente existente no 4macro (e ativo)
  sids_sub13 <- str_sub(sids_by_group$sid, 1, 13)
  sids_to_send <- sids_by_group$sid[sids_sub13 %in% sids_4macro]

  sids_to_send_metadata <- sids_by_group %>%
    filter(sid %in% sids_to_send)

  print(paste0("Enviando as aberturas para o indicador: ", i))

  post_series(indicators_metadado = sids_to_send_metadata,
              token = token_dev,
              url_dev)

  del_sids <- select_sids_to_del(indicator = i,
                                 new_sids = sids_to_send,
                                 token = token_dev)

  if(!identical(del_sids, character(0))) {
    print(paste0("Deletando aberturas indesejadas do indicador: ", i))
    delete_series(indicator = i,
                  del_series = del_sids,
                  token = token_dev)
  } else {
    print(paste0("Sem aberturas para excluir para o indicador ", i))
  }
  Sys.sleep(0.5)
}


