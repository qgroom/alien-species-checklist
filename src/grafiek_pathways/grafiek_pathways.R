library(dplyr)
library(ggplot2)
library(INBOtheme) # install with devtools: install_github("inbo/inboTheme")
library(tidyr)
library(grid)

# gebruik een RStudio project! Dan heb je geen setwd() nodig
setwd("~/githubs/inbo_alien-species-checklist/src/grafiek_pathways")

dataset <- read.csv(
    "../../data/interim/pathway_figure_data.tsv",
    sep = "\t"
)

# Make category capital letters
dataset <- mutate_at(dataset, .cols = c("category"), .funs = toupper)

# automatically create multiliners for x-axis,
# splitting on the first space after the center
label.splitter <- function(label, maxlength){
    label <- as.character(label)
    if (nchar(label) > maxlength) {
        # find space closest to center of string
        split.space <- nchar(label) %/% 2
        regex.statement <- paste("(^.{", split.space, "})(\\S*)([ ])", sep = "")
        label <- gsub(regex.statement, "\\1\\2\n", label)
    }
    return(label)
}
# subcategory add line splits
max.length.allowed <- 30
dataset$subcategory <- as.factor(sapply(dataset$subcategory,
                                        FUN = label.splitter,
                                        max.length.allowed))
# category add line splits
max.length.allowed <- 20
dataset$category <- as.factor(sapply(dataset$category,
                                     FUN = label.splitter,
                                     max.length.allowed))

# Create the graph
ggplot(dataset, aes(x = reorder(subcategory, -count_species_key),
                    y = count_species_key)) +
    geom_bar(stat = "identity", width = .65) +
    geom_text(aes(label = count_species_key), y = .1, vjust = 0.5,
              size = 4, angle = 90, hjust = 1.2) +
    ylab("Number of species") +
    facet_grid(. ~ category, scales = "free_x",
               space = "free_x") +
    theme_inbo2015(base_size = 11) +
    theme(
        axis.text.x = element_text(angle = 90, hjust = 1,
                                   vjust = 0.2, size = 10),
        axis.title.x = element_blank(),
        axis.text.y = element_text(size = 12, angle = 90,
                                   hjust = 0.5),
        axis.title.y = element_text(size = 14),
        strip.text.x = element_text(angle = 90, size = 12)
        )
# Remark: Rotation of the figure should done outside ggplot
ggsave("pathway_graph.png", width = 30, height = 33,
       units = "cm", dpi = 150)
