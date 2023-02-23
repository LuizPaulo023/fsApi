#' @title Script de exemplos com as funções - fsApi
#' @description Busca-se testar as funções do pkg fsApi
#' @author Luiz Paulo Tavares Gonçalves

rm(list = ls())
graphics.off()

# install.packages("devtools")
# devtools::install_github("LuizPaulo023/fsApi", ref = "main")

library(fsApi)
library(tidyverse)
library(httr)

# Definindo o Token do usuário - homologação ----------------------------------------------------------

token_homo = c(
  'Authorization' = 'INSIRA O TOKEN AQUI',
  'Content-Type' = 'application/json'
)

# Definindo o Token do usuário - produção --------------------------------------------------------------------------

token_prod = c(
  'Authorization' = 'INSIRA O TOKEN AQUI',
  'Content-Type' = 'application/json'
)

# Novas Aberturas ---------------------------------------------------------------------------------------

send_transf = fsApi::post.series(indicator_code = "BRIND0046",
                                 transfs_code = c("RJ2OOML",
                                                  "SP2OOML"),
                                 units_en = c("teste_Índice",
                                              "teste_Índice"),
                                 units_pt = c("teste_pt",
                                              "teste_pt"),
                                 token = token_homo)

# Retorna os nós (mestres) presentes na FS -------------------------------------------

fsApi::get.master_node(token = token_prod)

# Requisitando a árvore FS (prod) --------------------------------------------------------------------

tree_all = fsApi::get.tree(master_node = "all",
                           token = token_prod)

db_tree = fsApi::get.tree(master_node = "Brazil",
                          token = token_prod)

# Consultando o body que precisa ser preenchido --------------------------------------------

fsApi::get.body()

# Criando indicadores -----------------------------------------------------------------------------------------
#apply(table_complet, 1, post.indicator)


send_indicadores = post.indicator(name_en = "ARG - Exports of Goods",
                                  name_pt = "ARG - Exportações de Bens",
                                  short_en = "Export. Goods",
                                  short_pt = "Exp. Bens",
                                  source_en = "Indec",
                                  source_pt = "Indec",
                                  description_en = "....",
                                  description_pt = "...",
                                  description_full_en = "...",
                                  description_full_pt = "...",
                                  # Refatorar, retirar unit ----
                                  #unit = "USD Milhões",
                                  country = "AR",
                                  sector = "BOP",
                                  acess_group = "Geral",
                                  id_node = list_id)
# ---------------------------------------------------------------------------------------

