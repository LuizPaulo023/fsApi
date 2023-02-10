#' @title Consultar nó mestre, isto é, o primeiro nó
#' @name get.master_node
#'
#' @description A função busca consultar os nós (mestres) da árvore da FS
#'
#' @param token representa o token de acesso a FS;
#'
#' @author Luiz Paulo Tavares Gonçalves
#'
#' @details O token necessariamente precisa está no formato de string
#'
#' @return O retorno é um tibble com todos os nós da primeira ramificação
#' @examples
#' \dontrun{
#'
#' fs_master_node = fsApi::get.master_node(token = token_prod)
#'
#' }
#'
#' @export


get.master_node = function(token = as.character()){

    tree = get.tree(master_node = "list",
                    token = token)

    master_node = tree %>%
          purrr::map_df(function(x) {
          dplyr::tibble(master_node = x$node)
         }
    )


return(master_node)

}



