library(plyr)
library(ggplot2)
# Expects working directory set to "MeyerPlanes"
reduced.path <- file.path(getwd(), "Data", "Patents", "patents_small.csv")

reduced.df <- read.csv(file = reduced.path, as.is = TRUE, header = FALSE)

# --- define languages in order listed in file ---
langs.str <- c('Britain','Germany','France','United States')

names(reduced.df) <- c("Year", "Country", langs.str)
# Replace values in country column with full names
reduced.df[, "Country"] <- langs.str[match(reduced.df[, "Country"], c("br", "de", "fr", "us"))]

# Construct by year and by country-year tables
by.year.df <- ddply(reduced.df, "Year", "nrow")
by.year.country.df <- ddply(reduced.df, c("Year", "Country"), "nrow")
names(by.year.country.df)[3] <- names(by.year.df)[2] <- "Patents"

# Convert to factor for plotting
by.year.country.df[, "Country"] <- factor(by.year.country.df[, "Country"])

# Adjustable title and limits
beg_plot <- 1850 ##beg_year
end_plot <- 1910 ##end_year
country.title <- paste0("Aeronautically-relevant patents by country ", beg_plot, '-', end_plot)

# Summed by year
year.plot <- ggplot(data = subset(by.year.df, Year > beg_plot & Year <= end_plot),
                    aes(Year, Patents)) + geom_line() + xlab("") +
                    ylab('Patents') + 
                    opts(title = sub(" by country", "", country.title))

# summed by country (Different versions)
# Each of these can have a theme for publication added on later, meaning b/w, grayscale,
# etc. 

# basic ggplot2, no major changes
country.plot <- ggplot(data = subset(by.year.country.df, Year > beg_plot & Year <= end_plot), aes(Year, Patents, colour = Country)) +
                       geom_line(size = 1) + opts(title = country.title) +
                       xlab("") + ylab('Patents')
                       
# set to more closely match the original, without line type changes
inset.legend <- country.plot + opts(legend.background = theme_rect(fill="white"), 
                                    legend.justification=c(0,1), legend.position=c(0,1), 
                                    legend.text = theme_text(size = 16), title = country.title)
                               
# Show all countries seperately with common x axis for time. 
# labeller argument allows us to drop facet labels.
# See https://github.com/hadley/ggplot2/wiki/Faceting-Attributes


country.facet <- country.plot + facet_grid(Country ~ . , labeller = label_bquote('')) + 
  guides(colour = FALSE) + opts(strip.background = theme_rect(colour = NA, fill = NA),
                                plot.title = theme_text(size=20)) +
  geom_text(aes_string(x = 1855, y = 40, label = "Country"),
            show_guide = FALSE, hjust = 0, size = 7)

# I recommend against removing the grid lines but this is it w/ just the gray background

country.facet.degrid <- country.facet + opts(panel.grid.major=theme_blank(),panel.grid.minor=theme_blank())