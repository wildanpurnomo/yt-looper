<template>
  <v-app>
    <v-main>
      <v-container fill-height>
        <v-row align="center">
          <v-col cols="12" class="d-flex justify-center">
            <video controls ref="videoPlayer" class="video-js" />
          </v-col>
          <v-col cols="4">
            <v-text-field
              v-model="ytUrl"
              label="yt link"
              hint="https://www.youtube.com/watch?v=dQw4w9WgXcQ"
              persistent-hint
              outlined
            ></v-text-field>
          </v-col>
          <v-col cols="4">
            <v-text-field
              v-model="startTime"
              label="start time in second"
              hint="120 for 2:00"
              persistent-hint
              outlined
            >
            </v-text-field>
          </v-col>
          <v-col cols="4">
            <v-text-field
              v-model="endTime"
              label="end time in second"
              hint="120 for 2:00"
              persistent-hint
              outlined
            >
            </v-text-field>
          </v-col>
          <v-col cols="12" class="d-flex justify-center">
            <v-btn color="primary" @click="instantiatePlayer">Lezgo</v-btn>
          </v-col>
        </v-row>
      </v-container>
    </v-main>
  </v-app>
</template>

<script>
import "videojs-youtube";
import "video.js/dist/video-js.css";
import videojs from "video.js";
export default {
  name: "App",

  data: () => ({
    isFirstTime: true,
    player: null,
    ytUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    startTime: 30,
    endTime: 40,
    playerOptions: {
      width: "500px",
      height: "300px",
      techOrder: ["youtube"],
      sources: [],
    },
  }),

  methods: {
    onVideoTimeUpdate() {
      //console.log(`${player.cache_.currentTime} / ${player.cache_.duration}`);
      if (this.player.cache_.currentTime >= this.endTime) {
        this.isFirstTime = true;
        this.rewind();
      }
    },
    rewind() {
      if (this.isFirstTime) {
        this.isFirstTime = false;
        this.player.currentTime(this.startTime);
      }
    },
    instantiatePlayer() {
      this.disposePlayerIfExists();
      this.$set(
        (this.playerOptions.sources = [
          {
            type: "video/youtube",
            src: this.ytUrl,
          },
        ])
      );
      this.player = videojs(this.$refs.videoPlayer, this.playerOptions);
      this.player.on("timeupdate", this.onVideoTimeUpdate);
      this.player.on("play", this.rewind);
      this.player.on("ready", () => {
        this.player.play();
      });
    },
    disposePlayerIfExists() {
      if (this.player) {
        this.player.dispose();
      }
    },
  },

  beforeDestroy() {
    this.disposePlayerIfExists();
  },
};
</script>
