const Discord = require('discord.js');
const { Client, MessageEmbed } = require('discord.js');
const fetch = require('node-fetch');

require('dotenv').config();

const client = new Discord.Client();

client.on('ready', () => {
    console.log('Bot is ready');

    checkNotifs();
});

client.login(process.env.BOT_TOKEN2); //loads discord token from environment variables file

const { exit } = require('process');

async function sendmsg(id, command) {

    if (id !== "none") {

        if (command == "block") message = ":money_mouth: Your farm just found a block!";
        else if (command == "plot") message = ":tada: Your farm just completed another plot.";
        else if (command == "offline") message = ":skull_crossbones: Lost connection to farmer/harvester!";
        else if (command == "stopped") message = ":scream: Your farmer stopped farming!";

        const user = await client.users.fetch(id).catch(() => null);

        if (!user) console.log("User not found:(");

        await user.send(message).catch(() => {
            console.log("User has DMs closed or has no mutual servers with the bot:(");
        });

    }

}

const db_config = {
    host: 'localhost',
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: 'chiabot',
    waitForConnections: true,
    connectionLimit: 1
};

async function checkNotifs() {

    const mysql = require('mysql2/promise');

    while (true) {

        const connection = await mysql.createConnection(db_config); // Recreate the connection, since

        [results, fields] = await connection.execute('SELECT notificationID,user,type from notifications');

        for (var i = 0; i < results.length; i++) {
            var result = results[i];
            var notificationID = result['notificationID'];
            var userID = result['user'];
            var type = result['type'];

            await connection.execute('DELETE from notifications where notificationID=' + notificationID);

            console.log(type + " " + userID);

            //sends notification
            await sendmsg(userID, type);

        }

        await updateStatus(connection);

        //sleep 1 minute
        await sleep(1 * 60 * 1000);

    }

}

var userCount = 0;
var devicesCount = 0;

async function updateStatus(connection) {

    [results1, fields1] = await connection.execute(
        "SELECT user FROM farms WHERE data<>'' AND data<>';' AND user<>'none' group by user");

    userCount = results1.length;
    
    [results2, fields2] = await connection.execute(
        "SELECT id FROM farms WHERE data<>'' AND data<>';'");

    devicesCount = results2.length;

    //thanks big O!
    var status = userCount + " users, " + devicesCount + " devices";
    client.user.setActivity(status, { type: "LISTENING" });
}

//https://stackoverflow.com/questions/30514584/delay-each-loop-iteration-in-node-js-async
async function sleep(millis) {
    return new Promise(resolve => setTimeout(resolve, millis));
}





