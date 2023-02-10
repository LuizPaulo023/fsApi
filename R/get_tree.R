#' @title Árvore da FS
#' @name get.tree
#'
#' @description A função busca consultar a árvore FS
#'
#' @param token representa o token \code{token};
#' @param master_node representa o nó mestre desejado
#'
#' @author Luiz Paulo Tavares Gonçalves
#'
#' @details
#'
#' \code{master_node} além do parâmetro aceitar o nome de cada nó mestre desejado, há possibilidade de passar como parâmetro "all" para retornar todos os nós presentes na árvore da FS.
#'
#' @examples
#' \dontrun{
#'
#' tree = fsApi::get.tree(master_node = "Brazil",
#'                        token = token_prod)
#' }
#'
#' @export

get.tree <- function(master_node = as.character(),
                     token = as.character()){

      db_fs = httr::VERB("GET", url = "https://4i-featurestore-prod-api.azurewebsites.net/api/v1/domains",
                    add_headers(token)) %>%
              httr::content("parsed")

      tree = db_fs[["tree"]] # Puxando apenas árvore da lista

      if(master_node == "all"){

      tree = data.frame(tree = cbind(tree))

        }else if(master_node == "list"){

      tree = db_fs[["tree"]]

  }else{

number_node = tree |>
       purrr::map_df(function(index) {
       dplyr::tibble(node = index$node)
       }
  ) %>% dplyr::mutate(n = 1:length(tree)) %>%
        dplyr::filter(node == master_node) %>%
        dplyr::select(n)

      tree = data.frame(tree = cbind(tree))[[1]][[number_node$n]]

   }

   return(tree)

}






