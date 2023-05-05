library(tidyverse)
library(httr)

# Definindo parâmetros do usuário - dev  ----------------------------------------------------------

token_dev = c(
  'Authorization' = '',
  'Content-Type' = 'application/json'
)

url_dev = 'https://run-4i-dev-4casthub-featurestore-api-mhiml2nixa-ue.a.run.app/'

# Definindo o Token do usuário - homologação ----------------------------------------------------------

token_hmg = c(
  'Authorization' = '',
  'Content-Type' = 'application/json'
)

url_hmg = 'https://run-4i-stg-4casthub-featurestore-api-ht3a3o3bea-ue.a.run.app/'

# Definindo o Token do usuário - produção --------------------------------------------------------------------------

token_prod = c(
  'Authorization' = 'Bearer INSIRA O TOKEN DE ACESSO',
  'Content-Type' = 'application/json'
)

url_prod = 'https://run-prod-4casthub-featurestore-api-zdfk3g7cpq-ue.a.run.app/'


ambiente = 'dev' #opções: dev, stg, prod

if(ambiente == 'dev') {
  token_to_use = token_dev
  url_to_use = url_dev
} else if (ambiente == 'stg') {
  token_to_use = token_hmg
  url_to_use = url_hmg
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
  filter(descontinuada == 'FALSE') %>% 
  filter(is.na(nao_migrar)) %>% 
  filter(str_detect(grupo_4macro, c('Geral'))) %>% 
  filter(crawler == 'yahoo_finance')
         
#i = unique(metadados_filt[1,]$indicator_code)
#154 = EUGDP0099

for (i in unique(metadados_filt$indicator_code)) {
  df_filt <- metadados_filt %>%
    filter(indicator_code == i)

  #Gera todos os SIDs a partir do Subgrupo
  sids_by_group <- gen_sids_by_group(indicators_metadado = df_filt,
                                     depara_grupos = grupo_transf,
                                     depara_unidade = depara_unidade)

  #Mantem apenas os SIDs com a combinação de região+transf_primaria
  #Previamente existente no 4macro (e ativo)
  sids_sub13 <- str_sub(sids_by_group$sid, 1, 13)
  sids_to_send <- sids_by_group$sid[sids_sub13 %in% sids_4macro]

  sids_to_send_metadata <- sids_by_group %>% 
    #filter(str_sub(sid, 13,13) == 'O')
    filter(sid %in% sids_to_send)
  
  print(paste0("Enviando as aberturas para o indicador: ", i))
  
  if(sids_to_send_metadata %>% nrow() != 0){
    
    post_series(indicators_metadado = sids_to_send_metadata,
                token = token_to_use,
                url = url_to_use)
  } else {
    F
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
  } else {
    print(paste0("Sem aberturas para excluir para o indicador ", i))
  }
  
  Sys.sleep(0.5)
}


