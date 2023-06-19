#' @title ID dos nós da árvore
#' @name get.id
#'
#' @description A função retorna os IDs dos nós e dos filhos da árvore da FS
#'
#' @author Gabriel Bellé
#'
#' @param \code{tree} representa uma lista com a árvore da FS
#' @param \code{node} representa o nó com seus respectivos filhos que deseja acessar
#'
#' @return O retorno é Tibble os IDs do nós e filhos selecionados
#'
#' @examples
#'
#' \dontrun{
#'
#' ids_fs = fsApi::get.id(tree = db_tree,
#'                        node = "Brazil")
#' }
#'
#' @export

get.id <- function(tree = as.list(),
                   node = as.character()) {
  
  #Split nos Nodes
  node_vct = node %>%
    stringr::str_split(",") %>% 
    str_trim()
  
  node_lvls = base::length(node_vct)
  
  output <- tibble::tibble(node = tree$node,
                           id = tree$id)
  
  #Retorna ID do país, ou entra na árvore
  
  if(node_lvls == 1) {
    return(output)
  } else {
    tree_children <- tree$children
    
    #Por qtd de nodes
    for (lvl_n in 2:node_lvls) {
      n_children <- length(tree_children)
      
      #Opções de children
      for (lvl_c in 1:n_children) {
        check_node = ifelse(tree_children[[lvl_c]]$node == node_vct[[lvl_n]],
                            T, F)
        
        if(check_node) {
          output <- output %>%
            dplyr::bind_rows(tibble(node = tree_children[[lvl_c]]$node,
                                    id = tree_children[[lvl_c]]$id))
          
          if(lvl_n < node_lvls){
            tree_children = tree_children[[lvl_c]]$children
            break
          } else {
            return(output)
          }
        }
        if(lvl_c == n_children) {
          return(tibble(id = 500))
        }
      }
    }
  }
}

