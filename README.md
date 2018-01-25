Draw a graphic of members of an organisation by their country of origin.
===

The script provides an example how to access API to get country flags, and draw a pie chart using ggplot2

Current limitations:
1. I have not found a good way to embed a SVG file into a R visualisation __within R__, namely not using tools like *ImageMagick* and *Inkscape*.
2. Country names have to be correct, otherwise the REST API won't return the correct content that needs to be parsed. This happens for instance to 'Russia', which should be 'Russian Federation'.


