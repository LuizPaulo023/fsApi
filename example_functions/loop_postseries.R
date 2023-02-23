#' @title Script de exemplos com as funções - fsApi
#' @description Busca-se testar as funções do pkg fsApi
#' @author Luiz Paulo Tavares Gonçalves

# install.packages("devtools")
# devtools::install_github("LuizPaulo023/fsApi", ref = "main")

#library(fsApi)

library(tidyverse)
library(httr)

# Definindo o Token do usuário - homologação ----------------------------------------------------------

token_homo = c(
  'Authorization' = 'Bearer INSIRA O TOKEN DE ACESSO',
  'Content-Type' = 'application/json'
)

# Definindo o Token do usuário - produção --------------------------------------------------------------------------

token_prod = c(
  'Authorization' = 'Bearer INSIRA O TOKEN DE ACESSO',
  'Content-Type' = 'application/json'
)

# Novas Aberturas ---------------------------------------------------------------------------------------

belle_path <- 'C:/Users/GabrielBelle/4intelligence/Feature Store - Documentos/DRE/Documentação/migracao'

indicators_raw <- readxl::read_excel('grupos_transfs_FS.xlsx') %>%
                  select(codigo, grupo, subgrupo, regioes)

indicators <- indicators_raw %>%
  filter(grupo == 'Juros') %>%
  mutate(grupo = paste0(grupo, ' - ', subgrupo),
         regioes = ifelse(regioes == '0', '000', regioes))

grupo_transf <- readxl::read_excel(paste0(belle_path,
                                          '/diagrama_grupo_transfs.xlsx'),
                                   sheet = 'depara') %>%
  pivot_longer(cols = everything(),
               names_to = 'grupo',
               values_to = 'transfs') %>%
  arrange(grupo) %>%
  filter(!is.na(transfs))

indicators_to_send <- indicators %>%
  left_join(grupo_transf) %>%
  mutate(transf_sec = str_sub(transfs, 4,4),
         unit_pt = case_when(
           transf_sec == 'X' ~ '% a.d',
           transf_sec == 'N' ~ '% a.a',
           transf_sec == 'G' ~ '% a.a'
         ),
         unit_en = case_when(
           transf_sec == 'X' ~ '% p.d',
           transf_sec == 'N' ~ '% p.a',
           transf_sec == 'G' ~ '% p.a'
         ))

for (i in unique(indicators_to_send$codigo)) {

  fsApi::delete_series(indicator = i,
                       token = token_homo)

  df_filt <- indicators_to_send %>%
    filter(codigo == i)

  send_transf = fsApi::post.series(indicator_code = i,
                            region_code = unique(df_filt$regioes),
                            transfs_code = unique(df_filt$transfs),
                            units_en = unique(df_filt$unit_en),
                            units_pt = unique(df_filt$unit_pt),
                            token = token_homo)

}



