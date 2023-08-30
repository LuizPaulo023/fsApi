#' @title Alterando aberturas/transformações presentes na FS
#' @author Luiz Paulo T. Gonçalves
#' @details A função é dependente das funções get_id e get_tree

body_indicator <- function(indicator = as.character(),
                           ranking = as.numeric(),
                           access_type = as.character(),
                           access_group = as.character(),
                           name_en = as.character(),
                           name_pt = as.character(),
                           short_en = as.character(),
                           short_pt = as.character(),
                           source_en = as.character(),
                           source_pt = as.character(),
                           description_en = as.character(),
                           description_pt = as.character(),
                           description_full_en = as.character(),
                           description_full_pt = as.character(),
                           country,
                           sector,
                           node_en = as.character(),
                           node_pt = as.character(),
                           proj_owner) {
  
  input <- tibble::tibble(access_type = access_type,
                          access_group = access_group,
                          indicator_code = indicator,
                          name_en = name_en,
                          name_pt = name_pt,
                          short_name_en = short_en,
                          short_name_pt = short_pt,
                          source_en = source_en,
                          source_pt = source_pt,
                          description_en = description_en,
                          description_pt = description_pt,
                          description_full_en = description_full_en,
                          description_full_pt = description_full_pt,
                          country = country,
                          sector = sector,
                          node_en = list(node_en),
                          node_pt = list(node_pt))
  
  if(any(is.na(node_en))) {
    return(300)
  }
  
  id_nodes = get.id(tree = get.tree(master_node = base::strsplit(input$node_en[[1]], ", ")[[1]][1],
                                    token = token,
                                    url = url),
                    node = str_trim(input$node_en[[1]]))
  
  if(id_nodes$id[1] == 500) {
    return(500)
  }
  
  id_nodes = tibble::tibble(node = id_nodes$node,
                            id = id_nodes$id,
                            node_pt = node_pt)
  
  body = '{
 "access_type": "jesus",
  "indicator_code": "i_code",
  "name": {
    "en-us": "name_en",
    "pt-br": "name_pt"
  },
  "short_name": {
    "en-us": "short_en",
    "pt-br": "short_pt"
  },
  "source": {
    "en-us": "source_en",
    "pt-br": "source_pt"
  },
  "description": {
    "en-us": "description_en",
    "pt-br": "description_pt"
  },
  "description_full": {
    "en-us": "description_full_en",
    "pt-br": "description_full_pt"
  },
  "country": "countrys",
  "sector": "sectores",
  "access_group": "groups",
  "is_active": true,
  "projections": "aslas",
  "ranking": posicao,
  "tree": [
    {
      "id": "id_one",
      "node": "node_one",
      "name": {
        "en-us": "name_one_tree_en",
        "pt-br": "name_one_tree_pt"
      }
    }';
  
  adicional_body = ',
    {
      "id": "{a}",
      "node": "{b}",
      "name": {
        "en-us": "{b}",
        "pt-br": "{c}"
      }
    }'
  
  for (i in 2:nrow(id_nodes)) {
    #Primeiro node é substituido em outro passo
    result <- adicional_body %>% 
      str_replace_all(c('\\{a\\}'= id_nodes[i,]$id,
                        '\\{b\\}'= id_nodes[i,]$node,
                        '\\{c\\}'= id_nodes[i,]$node_pt))
    
    body <- body %>% 
      paste0(result)
  }
  #Fecha o json
  body <- body %>% 
    paste0('
  ]
}')
  
  send_fs = input %>%
    dplyr::mutate(body = body,
                  body_json = stringr::str_replace_all(body,
                                                       c("posicao" = as.character(ranking),
                                                         "jesus" = access_type,
                                                         "i_code" = indicator_code,
                                                         "aslas" = proj_owner,
                                                         "name_en" = name_en,
                                                         "name_pt" = name_pt,
                                                         "short_en" = short_en,
                                                         "short_pt" = short_pt,
                                                         "source_en" = source_en,
                                                         "source_pt" = source_pt,
                                                         "description_en" = description_en,
                                                         "description_pt" = description_pt,
                                                         "description_full_en" = description_full_en,
                                                         "description_full_pt" = description_full_pt,
                                                         "countrys" = country,
                                                         "sectores" = sector,
                                                         "groups" = access_group,
                                                         # Nodes, IDS - Parte das funções
                                                         "id_one" = id_nodes[1,]$id,
                                                         "node_one" = id_nodes[1,]$node,
                                                         "name_one_tree_en" = strsplit(input$node_en[[1]], ",")[[1]][1],
                                                         "name_one_tree_pt" = strsplit(input$node_pt[[1]], ",")[[1]][1]
                                                       ))) %>% 
    dplyr::select(-body)
  
  return(send_fs)
}


