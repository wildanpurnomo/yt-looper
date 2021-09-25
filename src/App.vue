<template>
  <v-app>
    <v-main>
      <v-container fill-height>
        <v-row align="center">
          <v-col id="videoPlayerParent" cols="12" class="d-flex justify-center">
            <video
              id="videoPlayer"
              controls
              ref="videoPlayer"
              class="video-js"
            />
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
            <v-btn color="primary" @click="initiatePlayLoop">Lezgo</v-btn>
          </v-col>
          <v-col cols="12">
            <h3>Last played</h3>
          </v-col>
          <v-col
            cols="4"
            v-for="(item, index) in dummyHistories"
            :key="index"
            style="cursor: pointer"
            @click="onHistoryItemClicked(item)"
          >
            <v-card>
              <v-img max-height="200" :src="item.thumbnail"></v-img>
            </v-card>
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
import HistoryModel from "@/models/history.model";
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
      muted: true,
      width: "500px",
      height: "300px",
      techOrder: ["youtube"],
      sources: [],
    },
    cacheYtUrlKey: "ytUrl",
    cacheStartKey: "start",
    cacheEndKey: "end",
    cacheLastPlayedKey: "lastPlayed",
    dummyHistories: [
      new HistoryModel(
        "https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg",
        "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
        "1:00",
        "1:10"
      ),
      new HistoryModel(
        "https://img.youtube.com/vi/mP0Ej28JeCs/0.jpg",
        "https://www.youtube.com/watch?v=mP0Ej28JeCs",
        "2:00",
        "2:10"
      ),
    ],
  }),

  computed: {
    videoPlayerParent() {
      return document.getElementById("videoPlayerParent");
    },
    startTimeInSecond() {
      return this.calculateSeconds(this.startTime);
    },
    endTimeInSecond() {
      return this.calculateSeconds(this.endTime);
    },
    lastPlayedClips() {
      return localStorage.getItem(this.lastPlayedClips)
        ? localStorage.getItem(this.lastPlayedClips)
        : [];
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
    initiatePlayLoop() {
      this.disposePlayerIfExists();
      this.cacheInputs();
      this.instantiatePlayer();
    },
    onHistoryItemClicked(historyModel) {
      this.ytUrl = historyModel.ytUrl;
      this.startTime = historyModel.startTime;
      this.endTime = historyModel.endTime;
      this.isFirstTime = true;

      this.cacheInputs();
      this.disposePlayerIfExists();
      this.recreateVideoPlayer();
      this.instantiatePlayer();
    },
    cacheInputs() {
      localStorage.setItem(this.cacheYtUrlKey, this.ytUrl);
      localStorage.setItem(this.cacheStartKey, this.startTime);
      localStorage.setItem(this.cacheEndKey, this.endTime);
    },
    instantiatePlayer() {
      this.$set(
        (this.playerOptions.sources = [
          {
            type: "video/youtube",
            src: this.ytUrl,
          },
        ])
      );
      this.player = videojs(
        document.getElementById("videoPlayer"),
        this.playerOptions
      );
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
      if (this.player != null) {
        this.player.dispose();
        this.player = null;
      }
    },
    recreateVideoPlayer() {
      let video = document.createElement("video");
      video.ref = "videoPlayer";
      video.controls = true;
      video.id = "videoPlayer";
      video.className = "video-js";
      this.videoPlayerParent.appendChild(video);
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
