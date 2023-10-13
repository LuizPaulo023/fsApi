library(tidyverse)
library(httr)

# Definindo parâmetros do usuário ----------------------------------------------------------

token_dev = c(
  'Authorization' = 'Bearer XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
  'Content-Type' = 'application/json'
)

url_dev = 'https://run-4i-dev-4casthub-featurestore-api-mhiml2nixa-ue.a.run.app/'

# Definindo parâmetros do usuário na API - ambiente Stg

token_stg = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iXX0sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvbmFtZSI6ImwudGF2YXJlc0A0aW50ZWxsaWdlbmNlLmNvbS5iciIsImlzcyI6Imh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDYzODdhOGY0OTExYmM1NjgyOTQyNWNmYSIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tL3VzZXJpbmZvIl0sImlhdCI6MTY5NzIwMDI1OSwiZXhwIjoxNjk3Mjg2NjU5LCJhenAiOiJLUW1ldnV3SVFvNVl3S0Zvb0dDVXJVZnNFVWk4eUszNCIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJwZXJtaXNzaW9ucyI6WyJjcmVhdGU6cHJvamVjdHMiLCJlZGl0OmFjY2Vzcy1ncm91cHMiLCJlZGl0OmluZGljYXRvcnMiLCJlZGl0Om15LWdyb3VwcyIsImVkaXQ6b2JzZXJ2YXRpb25zIiwiZWRpdDpwcmVkZWZpbmVkLWdyb3VwcyIsImVkaXQ6cHJvamVjdGlvbnMiLCJlZGl0OnNlcmllcyIsInJlYWQ6YWNjZXNzLWdyb3VwcyIsInJlYWQ6ZG9tYWlucyIsInJlYWQ6aW5kaWNhdG9ycyIsInJlYWQ6bXktZ3JvdXBzIiwicmVhZDpvYnNlcnZhdGlvbnMiLCJyZWFkOnByZWRlZmluZWQtZ3JvdXBzIiwicmVhZDpwcm9qZWN0aW9ucyIsInJlYWQ6cHJvamVjdHMiLCJyZWFkOnNlcmllcyJdfQ.mv_wfggVCjwfGn4ebcsing4tDE8j6se1dlzRkR5zCoLye1LaX7rniUmkMDIMVavpssdss67zp37HuQRFjgGAFl-qlPVgXsQVP8dgJbV2sb7hMwv_7VdN-Gu07rgCWRmL_0YWqYbgUihRaATjbeTJSSBuUOHsUumaDFo8bjCOK-WAMQ-kUevXECc6RjgIQbmUkFK6MUvNjyJ841wJ4tM8jkRq8SWb9f8xyGo72FOhgJ-6zCQe-mS8K9ZfNkjGCjjqaPXwvfqlq2AP0BXOdURoA361gkw69OBRL5SUC2YvpUba2NNJfGK1Gk869x0jVbkNIQG1p2zJTr3DhkqHXYfujg',
  'Content-Type' = 'application/json'
)

url_stg = "https://apis.4intelligence.ai/api-feature-store-stg/"
  # 'https://run-4i-stg-4casthub-featurestore-api-ht3a3o3bea-ue.a.run.app/'


# Definindo parâmetros do usuário na API - ambiente de produção

token_prod = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoibC50YXZhcmVzQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici91c2VyX21ldGFkYXRhIjp7fSwiaHR0cHM6Ly80aW50ZWxsaWdlbmNlLmNvbS5ici9hcHBfbWV0YWRhdGEiOnsicm9sZXMiOlsiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iXX0sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvbmFtZSI6ImwudGF2YXJlc0A0aW50ZWxsaWdlbmNlLmNvbS5iciIsImlzcyI6Imh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDYzODdhOGY0OTExYmM1NjgyOTQyNWNmYSIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vaG9tb2xvZ2F0aW9uLTRpbnRlbGxpZ2VuY2UudXMuYXV0aDAuY29tL3VzZXJpbmZvIl0sImlhdCI6MTY5Njk0Mjk5OCwiZXhwIjoxNjk3MDI5Mzk4LCJhenAiOiJLUW1ldnV3SVFvNVl3S0Zvb0dDVXJVZnNFVWk4eUszNCIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJwZXJtaXNzaW9ucyI6WyJjcmVhdGU6cHJvamVjdHMiLCJlZGl0OmFjY2Vzcy1ncm91cHMiLCJlZGl0OmluZGljYXRvcnMiLCJlZGl0Om15LWdyb3VwcyIsImVkaXQ6b2JzZXJ2YXRpb25zIiwiZWRpdDpwcmVkZWZpbmVkLWdyb3VwcyIsImVkaXQ6cHJvamVjdGlvbnMiLCJlZGl0OnNlcmllcyIsInJlYWQ6YWNjZXNzLWdyb3VwcyIsInJlYWQ6ZG9tYWlucyIsInJlYWQ6aW5kaWNhdG9ycyIsInJlYWQ6bXktZ3JvdXBzIiwicmVhZDpvYnNlcnZhdGlvbnMiLCJyZWFkOnByZWRlZmluZWQtZ3JvdXBzIiwicmVhZDpwcm9qZWN0aW9ucyIsInJlYWQ6cHJvamVjdHMiLCJyZWFkOnNlcmllcyJdfQ.TvOZplbw9jc9tSMF7wm53X5V9WJxPC8Dic6by_Con2f0qDyrjnvYF5O28F9AcYmRM8FU08saAfxBxmIYCpErSjzifj7oOQShx6KIkrteh0Qd5uPNt_s4LQRZ4QneckZi-OECr0W-kQQMTSWG4LWFzxSKShyUZnF42WM9doRsWy3ll5_Qb2Pgt10nwjovtusiLvCWOP23-8AFoVWn-hNbu1-CTnAw0Ssy-qkJTnoPyvhra-_fozbTCEFcM50PNiaeDwNFyc7Pvt-9v4dUrMb9dfCCHI09bm13evbRr-PfT4I-El0Opr5ORS-As0Vu8pFsPYcPU10BJrQgEgTxt5nhEw',
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

user = base::getwd() %>%
       stringr::str_extract("^((?:[^/]*/){3})") %>% print()

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

regioes_depara <- tibble(
  max = 'NO1, NE1, SE1, SU1, CO1',
  ufx = 'RO2, AC2, AM2, RR2, PA2, AP2, TO2, MA2, PI2, CE2, RN2, PB2, PE2, AL2, SE2, BA2, MG2, ES2, RJ2, SP2, PR2, SC2, RS2, MS2, MT2, GO2, DF2')

# Migração ----------------------------------------------------------------

# metadados <- readxl::read_excel(paste0(user, path, 'metadados_migração.xlsx'),
#                                 skip = 1) %>%
#   janitor::clean_names()

metadados <- readxl::read_excel("send_fs.xlsx") %>% 
              janitor::clean_names()


# metadados_filt <- metadados %>%
#   mutate(name_abv_pt_fs = iconv(name_abv_pt_fs,
#                                 from="UTF-8",to="ASCII//TRANSLIT"),
#          descontinuada = ifelse(is.na(descontinuada), 'FALSE', descontinuada)
#   ) %>%
#   #Organiza as regioes pro script
#   rename(regioes = regioes_4macro) %>%
#   mutate(regioes = str_replace_all(regioes, ' ', ','),
#          regioes = str_replace_all(regioes, 'MAX', regioes_depara$max),
#          regioes = str_replace_all(regioes, 'UFX', regioes_depara$ufx),
#          across(where(is.character), ~gsub('\r','', .x)),
#          across(where(is.character), ~gsub('\n','', .x))) %>%
#   #Organiza o grupo de transformação
#   rename(grupo = grupo_transformacao) %>%
#   #Limpa os indicadores que não serão enviados
#   #filter(grupo != 'Volume - EN - 2') %>%
#   filter(crawler == 'sidra_pnad')
#   #filter(str_detect(name_abv_pt_fs, 'PIB 4i'))
metadados_filt <- metadados
# Loop de envio -----------------------------------------------------------

problems = tibble(sid = c(), status = c())
sids_to_del <- tibble(ind = c(), sids = c())

for (i in unique(metadados_filt$indicator_code)) {
  df_filt <- metadados_filt %>%
    filter(indicator_code == "CNFXR0067")

  #Gera todos os SIDs a partir do Subgrupo
  sids_by_group <- gen_sids_by_group(indicators_metadado = df_filt,
                                     depara_grupos = grupo_transf,
                                     depara_unidade = depara_unidade)

  #Filtros específicos em cima do grupo de transf. gerado

  # sids_to_send_metadata <- sids_by_group  %>%
  #   rowwise() %>%
  #   filter(
  #     (!(str_sub(sid, 10, 12) %in% c(str_split(regioes_depara$ufx, ', ')[[1]],
  #                                   str_split(regioes_depara$max, ', ')[[1]], '000')) &
  #       str_sub(sid, 13, 13) == 'R') |
  #     (str_sub(sid, 13, 13) %in% c('R', 'O') &
  #        str_sub(sid, 10,12) %in% c(str_split(regioes_depara$ufx, ', ')[[1]],
  #                                    str_split(regioes_depara$max, ', ')[[1]], '000'))
  #   )

  sids_to_send_metadata <- sids_by_group %>%
    filter(str_sub(sid, 13, 13) != 'S') %>% 
    filter(str_sub(sid, 13, 13) != 'R')

  # sids_to_send_metadata <- sids_by_group %>%
  #   filter(str_sub(sid, 13,13) == 'O') %>%
  #   rowwise() %>%
  #   filter((str_sub(sid, 10,12) %in% str_split(regioes_depara$ufx, ', ')[[1]] &
  #            str_sub(sid, 16,16) == 'L') | !(str_sub(sid, 10,12) %in%
  #                                              str_split(regioes_depara$ufx, ', ')[[1]])) %>%
  #   ungroup()

  print(paste0("Enviando as aberturas para o indicador: ", i))

  if(sids_to_send_metadata %>% nrow() != 0){

   post_sid =  post_series(indicators_metadado = sids_to_send_metadata,
                          token = token_to_use,
                          url = url_to_use)
  } else {
    F
  }}
  problems = problems %>%
     bind_rows(post_sid)

  del_sids <- select_sids_to_del(indicator = i,
                                 new_sids = sids_to_send_metadata,
                                 token = token_to_use,
                                 url = url_to_use)

  sids_to_del <- sids_to_del %>%
    add_row(tibble(ind = i, sids = del_sids))

  if(!identical(del_sids, character(0))) {
    print(paste0("Deletando aberturas indesejadas do indicador: ", i))
    delete_series(indicator = i,
                  del_series = del_sids,
                  token = token_to_use,
                  url = url_to_use)
  } else {
    print(paste0("Sem aberturas para excluir para o indicador ", i))
  }

  Sys.sleep(1.0)
}


