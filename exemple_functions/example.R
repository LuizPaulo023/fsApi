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
  'Authorization' = 'Bearer INSIRA O TOKEN',
  'Content-Type' = 'application/json'
)

# Definindo o Token do usuário - produção --------------------------------------------------------------------------

token_prod = c(
  'Authorization' = 'Bearer INSIRA O TOKEN',
  'Content-Type' = 'application/json'
)

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

send_indicadores = fsApi::post.indicator(name_en = "BRA - Labor Force Participation Rate",
                                         name_pt = "BRA - Taxa de Participação na Força de Trabalho",
                                         short_en = "CIVPART",
                                         short_pt = "Taxa Partic.",
                                         source_en = "IBGE",
                                         source_pt = "IBGE",
                                         description_en = "...",
                                         description_pt = "...",
                                         description_full_en = "...",
                                         description_full_pt = "...",
                                         unit = "%",
                                         country = "BR",
                                         sector = "EMP",
                                         acess_group = "Geral",
                                         node_en = "Brazil, Economic activity, Labor market, Working population",
                                         node_pt = "Brasil, Atividade econômica, Mercado de trabalho, Força de trabalho")

# Novas Aberturas ---------------------------------------------------------------------------------------

send_transf = fsApi::post.series(indicator_code = "BREMP0120",
                                 transfs_code = c("RS2OOML",
                                                  "SC2OOML"),
                                 units = c("%", "%"),
                                 token = token_homo)
