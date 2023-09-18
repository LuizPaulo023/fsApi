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
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImpsUlBUc2FmM0MtZ3pITkdieTRYQSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoiZy5iZWxsZUA0aW50ZWxsaWdlbmNlLmNvbS5iciIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvdXNlcl9tZXRhZGF0YSI6e30sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvYXBwX21ldGFkYXRhIjp7InJvbGVzIjpbImlzRmFhUyIsImlzRmVhdHVyZVN0b3JlIiwiaXNGc0FkbWluIl19LCJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL25hbWUiOiJnLmJlbGxlQDRpbnRlbGxpZ2VuY2UuY29tLmJyIiwiaXNzIjoiaHR0cHM6Ly9ob21vbG9nYXRpb24tNGludGVsbGlnZW5jZS51cy5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NjI5OGY5ZTM4YWU1Y2UwMDY5MDcwNjAyIiwiYXVkIjpbIjRjYXN0aHViIiwiaHR0cHM6Ly9ob21vbG9nYXRpb24tNGludGVsbGlnZW5jZS51cy5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNjkyMTA5MzMzLCJleHAiOjE2OTIxOTU3MzMsImF6cCI6IktRbWV2dXdJUW81WXdLRm9vR0NVclVmc0VVaTh5SzM0Iiwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsInBlcm1pc3Npb25zIjpbImNyZWF0ZTpwcm9qZWN0cyIsImVkaXQ6YWNjZXNzLWdyb3VwcyIsImVkaXQ6aW5kaWNhdG9ycyIsImVkaXQ6bXktZ3JvdXBzIiwiZWRpdDpvYnNlcnZhdGlvbnMiLCJlZGl0OnByZWRlZmluZWQtZ3JvdXBzIiwiZWRpdDpwcm9qZWN0aW9ucyIsImVkaXQ6c2VyaWVzIiwicmVhZDphY2Nlc3MtZ3JvdXBzIiwicmVhZDpkb21haW5zIiwicmVhZDppbmRpY2F0b3JzIiwicmVhZDpteS1ncm91cHMiLCJyZWFkOm9ic2VydmF0aW9ucyIsInJlYWQ6cHJlZGVmaW5lZC1ncm91cHMiLCJyZWFkOnByb2plY3Rpb25zIiwicmVhZDpwcm9qZWN0cyIsInJlYWQ6c2VyaWVzIl19.D1_ivPGiVQX_SX1OF1P5JNC54UqoTuD7W6-GT40RX1XgsrMJrzpZLbVluZseVyKC2mHPParBAx99ttda6PSBmBaelbKYOM2-VfoxCpI6hk39bZGY9kFs8cpG5z3h-OxGf8Ln16quCZEW249VrcHoeylP2IggSLxf-n7kc-5l2KGflkHBVwsawNKdsqbqfHzvLUz4GVh748tgP81uPFYK44j-NRRR-fyL4ywmtU79d7w1c0LhQxU6PQNPzAT343R7V26IvWTvVh8AGZLLVOs_qlO-aRyqDUs1EfrpKRFYEJqOu2lqLHFw_m7JJoBXhVhKcvZkdlrlJAZMsRekDJqNgQ',
  'Content-Type' = 'application/json'
)

url_stg = 'https://run-4i-stg-4casthub-featurestore-api-ht3a3o3bea-ue.a.run.app/'

# Definindo parâmetros do usuário na API - ambiente de produção

token_prod = c(
  'Authorization' = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjgyX3VOQkNKVENnU0VNX3Z2TjR2LSJ9.eyJodHRwczovLzRpbnRlbGxpZ2VuY2UuY29tLmJyL2VtYWlsIjoiZy5iZWxsZUA0aW50ZWxsaWdlbmNlLmNvbS5iciIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvdXNlcl9tZXRhZGF0YSI6e30sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvYXBwX21ldGFkYXRhIjp7InJvbGVzIjpbImlzRWRpdG9yIiwiaXNGYWFTIiwiaXNGZWF0dXJlU3RvcmUiLCJpc0ZzQWRtaW4iLCJpc0JldGEiXSwic2hpbnlwcm94eV9yb2xlcyI6WyJmYWFzLWludGVybm8iLCJncGEiLCJ2aWF2YXJlam8iLCJhbmJpbWEiXX0sImh0dHBzOi8vNGludGVsbGlnZW5jZS5jb20uYnIvbmFtZSI6ImcuYmVsbGVANGludGVsbGlnZW5jZS5jb20uYnIiLCJpc3MiOiJodHRwczovLzRpbnRlbGxpZ2VuY2UuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDY0MDBkNTdlODU1Yzg0YzE5MTRhNzc0ZCIsImF1ZCI6WyI0Y2FzdGh1YiIsImh0dHBzOi8vNGludGVsbGlnZW5jZS5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNjkyMzA0ODMzLCJleHAiOjE2OTQ4OTY4MzMsImF6cCI6Im1TS1pxSDVLcTFXb2N4SmNsbklVUmJWSUtVV1Jqb0p6Iiwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsInBlcm1pc3Npb25zIjpbImNyZWF0ZTpwcm9qZWN0cyIsImVkaXQ6YWNjZXNzLWdyb3VwcyIsImVkaXQ6aW5kaWNhdG9ycyIsImVkaXQ6bXktZ3JvdXBzIiwiZWRpdDpvYnNlcnZhdGlvbnMiLCJlZGl0OnByZWRlZmluZWQtZ3JvdXBzIiwiZWRpdDpwcm9qZWN0aW9ucyIsImVkaXQ6c2VyaWVzIiwicmVhZDphY2Nlc3MtZ3JvdXBzIiwicmVhZDpkb21haW5zIiwicmVhZDppbmRpY2F0b3JzIiwicmVhZDpteS1ncm91cHMiLCJyZWFkOm9ic2VydmF0aW9ucyIsInJlYWQ6cHJlZGVmaW5lZC1ncm91cHMiLCJyZWFkOnByb2plY3Rpb25zIiwicmVhZDpwcm9qZWN0cyIsInJlYWQ6c2VyaWVzIl19.G5czyFdh_9fDH0lmYXZLS-p4wRY8o7LVZzHcR4uSeupMzzfXZw-2vqfNYvSkZbMl17E1P7Bn6vIHPQVHEeidAxrMuxeQB14os1cVbxwhl0Ii8RhYZAob2HVcRFOny_dMhlzt4oP8PDWjZ7nDGuU6qoOQjbU3kz3GHm5xtFObt6n6i5ecId-SNM5OBIdxTErP61e1PvQ3n2MY0Li-IrvdonmP10UXONkbtvI77hAIlSnlqWVWPg4tHS3kpXEi7EzRFPOiGuXaLqvfypZSkohV_nySlkMyYr-4ZcUf3hvtBf7eRji3Wx6tO5jppADZ6zhnQYD0mQBBjlmoVEA8vZaWiA',
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

metadados <- readxl::read_excel(paste0(user, path, 'metadados_migração.xlsx'),
                                skip = 1) %>%
  janitor::clean_names()

metadados_filt <- metadados %>%
  mutate(name_abv_pt_fs = iconv(name_abv_pt_fs,
                                from="UTF-8",to="ASCII//TRANSLIT"),
         descontinuada = ifelse(is.na(descontinuada), 'FALSE', descontinuada)
  ) %>%
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
  #filter(grupo != 'Volume - EN - 2') %>%
  filter(crawler == 'sidra_pnad')
  #filter(str_detect(name_abv_pt_fs, 'PIB 4i'))

# Loop de envio -----------------------------------------------------------

problems = tibble(sid = c(), status = c())
sids_to_del <- tibble(ind = c(), sids = c())

for (i in unique(metadados_filt$indicator_code)) {
  df_filt <- metadados_filt %>%
    filter(indicator_code == i)

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

  # sids_to_send_metadata <- sids_by_group %>%
  #   filter(str_sub(sid, 13, 13) %in% c('O'))

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
  }
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


