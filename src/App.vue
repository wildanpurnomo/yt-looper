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
              :hint="timeHint"
              persistent-hint
              outlined
            >
            </v-text-field>
          </v-col>
          <v-col cols="4">
            <v-text-field
              v-model="endTime"
              label="end time in second"
              :hint="timeHint"
              persistent-hint
              outlined
            >
            </v-text-field>
          </v-col>
          <v-col cols="12" class="d-flex justify-center">
            <v-btn color="primary" @click="onButtonClicked">Lezgo</v-btn>
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
    timeHint: "1:00, 12:00, 1:02:03",
    startTime: "0:00",
    endTime: "2:00",
    playerOptions: {
      width: "500px",
      height: "300px",
      techOrder: ["youtube"],
      sources: [],
    },
    cacheYtUrlKey: "ytUrl",
    cacheStartKey: "start",
    cacheEndKey: "end",
  }),

  computed: {
    startTimeInSecond() {
      console.log("start", this.calculateSeconds(this.startTime));
      return this.calculateSeconds(this.startTime);
    },
    endTimeInSecond() {
      console.log("end", this.calculateSeconds(this.endTime));
      return this.calculateSeconds(this.endTime);
    },
  },

  methods: {
    onVideoTimeUpdate() {
      //console.log(`${player.cache_.currentTime} / ${player.cache_.duration}`);
      if (this.player.cache_.currentTime >= this.endTimeInSecond) {
        this.isFirstTime = true;
        this.rewind();
      }
    },
    calculateSeconds(input) {
      let split = input.split(":");
      let timeInSecond = 0;
      if (split.length == 2) {
        split.forEach((item, index) => {
          if (index == 0) {
            timeInSecond += parseInt(item) * 60;
          } else {
            timeInSecond += parseInt(item);
          }
        });
      } else {
        split.forEach((item, index) => {
          if (index == 0) {
            timeInSecond += parseInt(item) * 3600;
          } else if (index == 1) {
            timeInSecond += parseInt(item) * 60;
          } else {
            timeInSecond += parseInt(item);
          }
        });
      }

      return timeInSecond;
    },
    rewind() {
      if (this.isFirstTime) {
        this.isFirstTime = false;
        this.player.currentTime(this.startTimeInSecond);
      }
    },
    onButtonClicked() {
      this.cacheInputs();
      this.instantiatePlayer();
    },
    cacheInputs() {
      localStorage.setItem(this.cacheYtUrlKey, this.ytUrl);
      localStorage.setItem(this.cacheStartKey, this.startTime);
      localStorage.setItem(this.cacheEndKey, this.endTime);
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
    populateCacheIfExists() {
      if (localStorage.getItem(this.cacheYtUrlKey)) {
        this.ytUrl = localStorage.getItem(this.cacheYtUrlKey);
        this.startTime = localStorage.getItem(this.cacheStartKey);
        this.endTime = localStorage.getItem(this.cacheEndKey);
      }
    },
    disposePlayerIfExists() {
      if (this.player) {
        this.player.dispose();
      }
    },
  },

  mounted() {
    this.populateCacheIfExists();
  },

  beforeDestroy() {
    this.disposePlayerIfExists();
  },
};
</script>
