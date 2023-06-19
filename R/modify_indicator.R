#' @title Alterando aberturas/transformações presentes na FS
#' @author Luiz Paulo T. Gonçalves
#' @details A função é dependente das funções get_id e get_tree

modify_indicator <- function(indicator = as.character(),
                             access_type = as.character(),
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
                             node_en = as.character(),
                             node_pt = as.character(),
                             token = as.character(),
                             url = as.character()){

# \\ Definindo o body
# \\ Preenchimento obrigatório de todos os campos do body
# \\ Adição na nova versão dos ID's e Nodes
# \\ Campo <indicador> não preencher o body

body = '{
  "access_type": "step_one",
  "description": {
    "en-us": "description_en",
    "pt-br": "description_pt"
  },
  "description_full": {
    "en-us": "description_full_en",
    "pt-br": "description_full_pt"
  },
  "is_active": true,
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
  "tree": [
    {
      "id": "id_one",
      "node": "node_one",
      "name": {
        "en-us": "name_one_tree_en",
        "pt-br": "name_one_tree_pt"
      }
    },
    {
      "id": "id_two",
      "node": "node_two",
      "name": {
        "en-us": "name_two_tree_en",
        "pt-br": "name_two_tree_pt"
      }
    },
    {
      "id": "id_three",
      "node": "node_three",
      "name": {
        "en-us": "name_three_tree_en",
        "pt-br": "name_three_tree_pt"
      }
    },
    {
      "id": "id_four",
      "node": "node_four",
      "name": {
        "en-us": "name_four_tree_en",
        "pt-br": "name_four_tree_pt"
      }
    },
    {
      "id": "id_five",
      "node": "node_five",
      "name": {
        "en-us": "name_five_tree_en",
        "pt-br": "name_five_tree_pt"
      }
    },
    {
      "id": "id_six",
      "node": "node_six",
      "name": {
        "en-us": "name_six_tree_en",
        "pt-br": "name_six_tree_pt"
      }
    }
    
  ]
}';

# Guardando os inputs ----------------------------------------------------------

input <- tibble::tibble(indicador = indicator,
                        access_type = access_type,
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
                        node_en = list(node_en),
                        node_pt = list(node_pt))

  # Chamando as funções para obter os ID's da árvore/nó ------------------------

id_nodes = get.id(tree = get.tree(master_node = base::strsplit(input$node_en, ", ")[1],
                                  token = token,
                                  url = url),
                  node = input$node_en[[1]])

id_nodes = tibble::tibble(node = c(id_nodes$node,
                                   rep("", 6-length(id_nodes$id))),
                          id = c(id_nodes$id,
                                 rep("", 6-length(id_nodes$id))))


# Preenchendo o JSON -----------------------------------------------------------
# \\Body

pull_fs = input %>%
          dplyr::rowwise() %>%
          dplyr::mutate(body = body,
                        body_json = stringr::str_replace_all(body,
                      c("step_one" = access_type,
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
                        # Nodes, IDS - Parte das funções
                        "id_one" = id_nodes[1,]$id,
                        "node_one" = id_nodes[1,]$node,
                        "name_one_tree_en" = strsplit(input$node_en[[1]], ", ")[[1]][1],
                        "name_one_tree_pt" = strsplit(input$node_pt[[1]], ", ")[[1]][1],
                        "id_two" = id_nodes[2,]$id,
                        "node_two" = id_nodes[2,]$node,
                        "name_two_tree_en" = ifelse(id_nodes[2,]$id == "",
                                                    "", strsplit(input$node_en[[1]], ",")[[2]]),
                        "name_two_tree_pt" = ifelse(id_nodes[2,]$id == "",
                                                    "", strsplit(input$node_pt[[1]], ",")[[2]]),
                        "id_three" = id_nodes[3,]$id,
                        "node_three" = id_nodes[3,]$node,
                        "name_three_tree_en" = ifelse(id_nodes[3,]$id == "",
                                                      "", strsplit(input$node_en[[1]], ",")[[3]]),
                        "name_three_tree_pt" = ifelse(id_nodes[3,]$id == "",
                                                      "", strsplit(input$node_pt[[1]], ",")[[3]]),
                        "id_four" = id_nodes[4,]$id,
                        "node_four" = id_nodes[4,]$node,
                        "name_four_tree_en" = ifelse(id_nodes[4,]$id == "",
                                                     "", strsplit(input$node_en[[1]], ",")[[4]]),
                        "name_four_tree_pt" = ifelse(id_nodes[4,]$id == "",
                                                     "", strsplit(input$node_pt[[1]], ",")[[4]]),
                        "id_five" = id_nodes[5,]$id,
                        "node_five" = id_nodes[5,]$node,
                        "name_five_tree_en" = ifelse(id_nodes[5,]$id == "",
                                                     "", strsplit(input$node_en[[1]], ",")[[5]]),
                        "name_five_tree_pt" = ifelse(id_nodes[5,]$id == "",
                                                     "", strsplit(input$node_pt[[1]], ",")[[5]]),
                        "id_six" = id_nodes[6,]$id,
                        "node_six" = id_nodes[6,]$node,
                        "name_six_tree_en" = ifelse(id_nodes[6,]$id == "",
                                                    "", strsplit(input$node_en[[1]], ",")[[6]]),
                        "name_six_tree_pt" = ifelse(id_nodes[6,]$id == "",
                                                    "", strsplit(input$node_pt[[1]], ",")[[6]])
                      ))) %>%  
                        # url = paste0(url,"api/v1/indicators")
                      dplyr::select(-body)

# Loop para alteração >1 um indicador

for (i in 1:length(pull_fs$indicador)) {
  # Exemplo base de URL
  #https://4i-featurestore-hmg-api.azurewebsites.net/api/v1/indicators/"
  alterando <- httr::VERB("PUT",
                          url = paste0(url, "api/v1/indicators/",
                                       pull_fs$indicador[i]),
                          body = pull_fs$body_json[i],
                          add_headers(token))

  cat(content(alterando, 'text'))
  
  return(alterando$status_code)
}
}


