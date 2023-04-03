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
  'Authorization' = 'XXXXXXXXXXXXXXXXXXX',
  'Content-Type' = 'application/json'
)

# Definindo o Token do usuário - produção --------------------------------------------------------------------------

token_prod = c(
  'Authorization' = 'XXXXXXXXXXXXXXXXXXX',
  'Content-Type' = 'application/json'
)

# Novas Aberturas ---------------------------------------------------------------------------------------
# ATENÇÃO ADICIONAR NOVAS PARÂMETROS AO CHAMAR A FUNÇÃO:

#' send_transf = fsApi::post.series(indicator_code = "BRBOP0001",
#'                                  region_code = c('AL2', 'GO2'),
#'                                  transfs_code = c("OOML", "OOMM"),
#'                                  units_en = c("teste1", "teste2"),
#'                                  units_pt = c("testea", "testeb")
#'                                  token = headers)


# Retorna os nós (mestres) presentes na FS -------------------------------------------

node_matres = fsApi::get.master_node(token = token_prod)

# Requisitando a árvore FS (prod) --------------------------------------------------------------------

tree_all = fsApi::get.tree(master_node = "all",
                           token = token_prod)

db_tree = fsApi::get.tree(master_node = "Brazil",
                          token = token_prod)

# Consultando o body que precisa ser preenchido --------------------------------------------

fsApi::get.body()

# Criando indicadores -----------------------------------------------------------------------------------------
# ATENÇÃO: A FUNÇÃO POST.INDICATOR É DEPENDENTE DAS FUNÇÕES {get.tree} e {get.id}

library(fsApi)

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
                                  country = "AR",
                                  sector = "BOP",
                                  acess_group = "Geral",
                                  node_en = "Argentina",
                                  node_pt = "Argentina")

# POST.indicator para dev ---------------------------------------------------------------------------------------


 send_indicadores = post.indicator(access_type = "default",
                                  indicator_code = "ARGDP0050",
                                  name_en = "ARG - Exports of Goods",
                                  name_pt = "ARG - Exportações de Bens",
                                  short_en = "Export. Goods",
                                  short_pt = "Exp. Bens",
                                  source_en = "Indec",
                                  source_pt = "Indec",
                                  description_en = "....",
                                  description_pt = "...",
                                  description_full_en = "...",
                                  description_full_pt = "...",
                                  country = "AR",
                                  sector = "BOP",
                                  acess_group = "Geral",
                                  node_en = "Argetina",
                                  node_pt = "Argentina")
