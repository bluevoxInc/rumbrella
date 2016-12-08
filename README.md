Rumbrella

Description:

Rumbrella is an umbrella project for the Rumbl application. It separates out the InfoSys component as an unbrella app. See Chapter 12 of the Programming Phoenix book for details.

Please refer to the umbrella apps' README files listed under the ./apps subdirectory for details on how to setup individual run environemnts.

RUMBL is:
A video annotation application written in Elixir/Phoenix. This code is based on the first 11 chapters of the Programming Phoenix book, v.P1.0 --April 2016.

NOTE: You must rename the ./apps/rumbl/config/dev.secret.dist to config/dev.secret and edit the line:

config :rumbl, :wolfram, app_id: "XXXXXX-XXXXXXXXXX"

to add your own Wolfram-Alpha id for the InfoSys component of this app to run properly.

To start your Phoenix app:

Install dependencies with mix deps.get
Create and migrate your database with mix ecto.create && mix ecto.migrate
Install Node.js dependencies with npm install
Start Phoenix endpoint with mix phoenix.server
Now you can visit localhost:4000 from your browser.
