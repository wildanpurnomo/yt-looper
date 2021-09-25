<template>
  <v-app>
    <v-main>
      <v-container fill-height>
        <v-row align="center">
          <v-col id="videoPlayerParent" cols="12" class="d-flex justify-center">
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
            <v-btn color="primary" @click="initiatePlayLoop">Lesgo</v-btn>
          </v-col>
          <v-col cols="12">
            <h3>Timestamps</h3>
          </v-col>
          <v-col cols="12">
            <h3>Last played</h3>
          </v-col>
          <v-col
            cols="4"
            v-for="(item, index) in clipHistories ? clipHistories : []"
            :key="index"
            style="cursor: pointer"
            @click="onHistoryItemClicked(item, index)"
          >
            <v-card>
              <v-img max-height="200" :src="getThumbnail(item.ytUrl)"></v-img>
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
    ytUrlRegex:
      /(?:youtube(?:-nocookie)?\.com\/(?:[^\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})/,
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
    clipHistoryKey: "history",
    lastPlayedClipIndexKey: "lastPlayedIndex",
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
    clipHistories() {
      return localStorage.getItem(this.clipHistoryKey)
        ? JSON.parse(localStorage.getItem(this.clipHistoryKey))
        : [];
    },
    lastPlayedClipIndex() {
      return localStorage.getItem(this.lastPlayedClipIndexKey)
        ? parseInt(localStorage.getItem(this.lastPlayedClipIndexKey))
        : 0;
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
      this.isFirstTime = true;
      this.disposePlayerIfExists();
      this.cacheInputs();
      this.createVideoPlayerElement();
      this.instantiatePlayer();
    },
    onHistoryItemClicked(historyModel, itemIndex) {
      localStorage.setItem(this.lastPlayedClipIndexKey, itemIndex.toString());
      this.ytUrl = historyModel.ytUrl;
      this.startTime = historyModel.startTime;
      this.endTime = historyModel.endTime;

      this.initiatePlayLoop();
    },
    cacheInputs() {
      if (this.isClipHistoryNotEmpty()) {
        if (this.isNewClip()) {
          this.appendClipToHistory();
        }
      } else {
        this.setNewClipHistory();
      }
    },
    appendClipToHistory() {
      let stored = this.clipHistories.slice();
      stored.unshift(
        new HistoryModel(this.ytUrl, this.startTime, this.endTime)
      );
      localStorage.setItem(this.clipHistoryKey, JSON.stringify(stored));
    },
    setNewClipHistory() {
      localStorage.setItem(
        this.clipHistoryKey,
        JSON.stringify([
          new HistoryModel(this.ytUrl, this.startTime, this.endTime),
        ])
      );
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
      if (this.isClipHistoryNotEmpty()) {
        this.ytUrl = this.clipHistories[this.lastPlayedClipIndex].ytUrl;
        this.startTime = this.clipHistories[this.lastPlayedClipIndex].startTime;
        this.endTime = this.clipHistories[this.lastPlayedClipIndex].endTime;
      }
    },
    disposePlayerIfExists() {
      if (this.player != null) {
        this.player.dispose();
        this.player = null;
      }
    },
    createVideoPlayerElement() {
      let video = document.createElement("video");
      video.ref = "videoPlayer";
      video.controls = true;
      video.id = "videoPlayer";
      video.className = "video-js";
      this.videoPlayerParent.appendChild(video);
    },
    getThumbnail(ytUrl) {
      return `https://img.youtube.com/vi/${
        ytUrl.match(this.ytUrlRegex)[1]
      }/0.jpg`;
    },
    isNewClip() {
      let copyOfHistory = this.clipHistories.slice();
      return (
        copyOfHistory.filter((item) => item.ytUrl == this.ytUrl).length == 0
      );
    },
    isClipHistoryNotEmpty() {
      return this.clipHistories.length > 0;
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
