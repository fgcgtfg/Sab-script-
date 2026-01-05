require("dotenv").config();
const { Client, GatewayIntentBits } = require("discord.js");
const { Player } = require("discord-player");
const { DefaultExtractors } = require("@discord-player/extractor");
const Spotify = require("@distube/spotify"); // We'll use a Spotify extractor

const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent,
    GatewayIntentBits.GuildVoiceStates,
  ],
});

const player = new Player(client);

(async () => {
  await player.extractors.loadMulti(DefaultExtractors);
})();

client.once("ready", () => {
  console.log(`✅ Logged in as ${client.user.tag}`);
});

client.on("messageCreate", async (message) => {
  if (!message.guild || message.author.bot) return;

  const prefix = "!";
  if (!message.content.startsWith(prefix)) return;

  const args = message.content.slice(prefix.length).trim().split(/ +/);
  const command = args.shift().toLowerCase();

  const queue = player.nodes.get(message.guild) || player.nodes.create(message.guild, { metadata: message.channel });

  // ----------------- PLAY SONG -----------------
  if (command === "play") {
    if (!message.member.voice.channel) return message.reply("❌ Join a voice channel first!");
    const query = args.join(" ");
    if (!query) return message.reply("❌ Provide a song name!");

    try {
      if (!queue.connection) await queue.connect(message.member.voice.channel);
      const result = await player.search(query, { requestedBy: message.author });
      if (!result.tracks.length) return message.reply("❌ No results found!");

      queue.addTrack(result.tracks[0]);
      if (!queue.isPlaying()) await queue.node.play();

      message.reply(`🎶 Now playing: **${result.tracks[0].title}**`);
    } catch (err) {
      console.error(err);
      message.reply("❌ Error playing song.");
    }
  }

  // ----------------- SPOTIFY SONG / PLAYLIST -----------------
  if (command === "spotify") {
    if (!message.member.voice.channel) return message.reply("❌ Join a voice channel first!");
    const query = args.join(" ");
    if (!query) return message.reply("❌ Provide a Spotify song or playlist link!");

    try {
      if (!queue.connection) await queue.connect(message.member.voice.channel);

      // Detect if it's a playlist link
      const isPlaylist = query.includes("playlist");

      let result;
      if (isPlaylist) {
        // Fetch playlist tracks (Spotify link)
        // We use YouTube search per track
        const playlistSearch = await player.search(query, { requestedBy: message.author });
        if (!playlistSearch.tracks.length) return message.reply("❌ No tracks found in this playlist!");
        queue.addTrack(playlistSearch.tracks);
        message.reply(`🎵 Added **${playlistSearch.tracks.length} songs** from Spotify playlist!`);
      } else {
        // Single track
        result = await player.search(query, { requestedBy: message.author });
        if (!result.tracks.length) return message.reply("❌ No results found!");
        queue.addTrack(result.tracks[0]);
        message.reply(`🎵 Now playing (Spotify search style): **${result.tracks[0].title}**`);
      }

      if (!queue.isPlaying()) await queue.node.play();
    } catch (err) {
      console.error(err);
      message.reply("❌ Error playing Spotify song or playlist.");
    }
  }

  // ----------------- JAZZ PLAYLIST -----------------
  if (command === "jazz") {
    if (!message.member.voice.channel) return message.reply("❌ Join a voice channel first!");
    try {
      if (!queue.connection) await queue.connect(message.member.voice.channel);

      const result = await player.search("smooth jazz playlist", { requestedBy: message.author });
      if (!result.tracks.length) return message.reply("❌ No jazz found!");

      queue.addTrack(result.tracks.slice(0, 20)); // queue 20 jazz songs
      if (!queue.isPlaying()) await queue.node.play();

      message.reply("🎷 Smooth jazz is now playing...");
    } catch (err) {
      console.error(err);
      message.reply("❌ Error playing jazz.");
    }
  }

  // ----------------- PAUSE -----------------
  if (command === "pause") {
    if (!queue || !queue.isPlaying()) return message.reply("❌ Nothing is playing.");
    queue.node.pause();
    message.reply("⏸️ Paused the music.");
  }

  // ----------------- RESUME -----------------
  if (command === "resume") {
    if (!queue || !queue.isPaused()) return message.reply("❌ Music is not paused.");
    queue.node.resume();
    message.reply("▶️ Resumed the music.");
  }

  // ----------------- SKIP -----------------
  if (command === "skip") {
    if (!queue || !queue.isPlaying()) return message.reply("❌ Nothing is playing.");
    queue.node.skip();
    message.reply("⏭️ Skipped the current song.");
  }

  // ----------------- STOP -----------------
  if (command === "stop") {
    if (!queue || !queue.isPlaying()) return message.reply("❌ Nothing is playing.");
    queue.delete();
    message.reply("⏹️ Music stopped and bot left the VC.");
  }

  // ----------------- QUEUE -----------------
  if (command === "queue") {
    if (!queue || !queue.tracks.size) return message.reply("📭 Queue is empty.");

    const tracks = queue.tracks.toArray().slice(0, 10).map((t, i) => `${i + 1}. ${t.title}`).join("\n");
    message.reply(`🎶 **Queue:**\n${tracks}`);
  }
});

client.login(process.env. MTQ1Nzc5Nzk4Mzg2ODQyMDMzMg.GjbUzz.KHjhox2Vyuf3wI6kaambj5NN5EPTYqNeQU2fIc);
