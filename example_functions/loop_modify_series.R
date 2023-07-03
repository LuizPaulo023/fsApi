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
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgyX3VOQkNKVENnU0VNX3Z2TjR2LSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNFZGl0b3IiLCJpczRpIiwiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iLCJpc0JldGEiXSwic2hpbnlwcm94eV9yb2xlcyI6WyJiZG1nIl19LCJpc3MiOiJodHRwczovLzRpbnRlbGxpZ2VuY2UuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDYyMzRjNDI0YTE4ZjM3MDA2OGI3MTFkOSIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNjg3ODY3Mzk4LCJleHAiOjE2OTA0NTkzOTgsImF6cCI6Im1TS1pxSDVLcTFXb2N4SmNsbklVUmJWSUtVV1Jqb0p6Iiwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsInBlcm1pc3Npb25zIjpbImNyZWF0ZTpwcm9qZWN0cyIsImVkaXQ6YWNjZXNzLWdyb3VwcyIsImVkaXQ6aW5kaWNhdG9ycyIsImVkaXQ6bXktZ3JvdXBzIiwiZWRpdDpvYnNlcnZhdGlvbnMiLCJlZGl0OnByZWRlZmluZWQtZ3JvdXBzIiwiZWRpdDpwcm9qZWN0aW9ucyIsImVkaXQ6c2VyaWVzIiwicmVhZDphY2Nlc3MtZ3JvdXBzIiwicmVhZDpkb21haW5zIiwicmVhZDppbmRpY2F0b3JzIiwicmVhZDpteS1ncm91cHMiLCJyZWFkOm9ic2VydmF0aW9ucyIsInJlYWQ6cHJlZGVmaW5lZC1ncm91cHMiLCJyZWFkOnByb2plY3Rpb25zIiwicmVhZDpwcm9qZWN0cyIsInJlYWQ6c2VyaWVzIl19.d--jkPpKhwgOtGWOtnpOdYGJsYtjvnl19KBB0ueYCXWqcOYva64kUWXhPylyZPDe5wvOVsv8rsNHUzVNIXOszDNVmdTPYFaFVFSR9OZFxlICF4zCXmkv2IwmeZHXQwmkxzAvMc_IK439wqhOesAxaFdL53qVL5bfw58E1CXBaWyVaCxWSVAZX8VHsmYu8zrtLaCzJPCmtaEHevezY2PqJYIQtt1tzlwGRa_w_4Uf6fyQx3DAo9VAZy7Dn8Df0nvqV5-Ka2jgGG9AcQKy2E_X_8g7eEHY2qza4nc9V0-JHas5rvZggwkBbYhaB5GlzkSWQpwes8j_IpgdiiFHpX5zlw',
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

# Metadados --------------------------------------------------------------------

metadados <- readxl::read_excel(paste0(user,
                                       path,
                                       'metadados_migração.xlsx'),
                                skip = 1) %>% janitor::clean_names()

# problem_units <- readxl::read_excel("unidade_teste.xlsx") %>% 
#                  rename(sids = serie) %>% 
#                  mutate(indicador = str_sub(sids, start = 1, end = 9)) 

metadados_filt <- metadados %>% 
  #Limpa os indicadores que não serão editados
  filter(descontinuada == 'FALSE') %>% 
  filter(is.na(nao_migrar)) %>% 
  filter(str_detect(grupo_4macro, c('Geral'))) %>% 
  #filter(in_fs) %>% 
  filter(indicator_code %in% c("MXBOP0028")) %>% 
  #filter(crawler != "petrobras") %>% 
  #filter(crawler %in% c("vli_acucar")) %>% 
  pluck('indicator_code')

# Unidade ----------------------------------------------------------------------

depara_unidade <- readxl::read_excel(paste0(user, path,
                                            '/diagrama_grupo_transfs.xlsx'),
                                     sheet = 'depara unidade medida')

# Chamando a função GET FS-series ----------------------------------------------
# Função está no script modify_series 

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


