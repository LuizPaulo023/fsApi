% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_tree.R
\name{get.tree}
\alias{get.tree}
\title{Árvore da FS}
\usage{
get.tree(master_node = as.character(), token = as.character())
}
\arguments{
\item{master_node}{representa o nó mestre desejado}

\item{token}{representa o token \code{token};}
}
\description{
A função busca consultar a árvore FS
}
\details{
\code{master_node} além do parâmetro aceitar o nome de cada nó mestre desejado, há possibilidade de passar como parâmetro "all" para retornar todos os nós presentes na árvore da FS.
}
\examples{
\dontrun{

tree = fsApi::get.tree(master_node = "Brazil",
                       token = token_prod)
}

}
\author{
Luiz Paulo Tavares Gonçalves
}
