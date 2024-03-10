# OhmMyGod
## What is it?
OhmMyGod is a battery app that shows you battery information. You can see how much percent your battery is, whether you are charging or not, and how long it will take your battery to be full/empty. The app has a simple and smooth UI.

The battery percentage gets visualised by a pie chart. This pie chart fills up along with your battery. It currently has 5 color modes:
- Green: when the battery is full (100%)
- Gray: when the battery is discharging (99%-21%)
- Blue: when the battery is charging (99%-21%)
- Orange: when the battery is low (20%-11%)
- Red: when the battery is super low (10%-1%)

## Things to keep in mind
The time that it will take for your battery to be full/empty is calculated by detecting the time it takes your phone to get 1% less/more and multiplying that time by the percentage your phone has left (to charge). This will not always be completely accurate, as phone batteries don't always charge or discharge consistently (please just don't sue me).

This app was made by someone who had no prior knowledge of Flutter 3 weeks ago. I did this project to develop my Flutter skills (and it worked out).