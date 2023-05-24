#' @title Alterando aberturas/transformações presentes na FS
#' @author Luiz Paulo T. Gonçalves
#' @details A função é dependente das funções get_id e get_tree

# rm(list = ls())

token_dev = c(
  'Content-Type' = 'application/json',
  'Authorization' = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
)

url_dev = 'https://run-4i-dev-4casthub-featurestore-api-mhiml2nixa-ue.a.run.app/'

# Testando Função ---------------------------------------------------------------------
# Se modify_ind = TRUE, alterar o indicador solicitado

teste = modify_indicator(modify_ind = TRUE,
                         indicator = "BRINR0002",
                         access_type = "default",
                         name_en = "teste",
                         name_pt = "TestandoFuncaoEnvio",
                         short_en = "teste",
                         short_pt = "teste",
                         source_en = "teste",
                         source_pt = "teste",
                         description_en = "teste",
                         description_pt = "teste",
                         description_full_en = "teste",
                         description_full_pt = "teste",
                         node_en = "Brazil",
                         node_pt = "Brasil",
                         token = token_dev,
                         url = url_dev)



