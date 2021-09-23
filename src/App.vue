<template>
  <v-app>
    <v-main>
      <v-container fill-height>
        <v-row align="center">
          <v-col cols="12" class="d-flex justify-center">
            <video-player
              ref="videoPlayer"
              class="video-player-box"
              :options="playerOptions"
              :playsinline="true"
              @timeupdate="onVideoTimeUpdate($event)"
              @play="onVideoStartsPlay($event)"
            >
            </video-player>
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
        </v-row>
      </v-container>
    </v-main>
  </v-app>
</template>

<script>
export default {
  name: "App",

  data: () => ({
    jobId: -1,
    isFirstTime: true,
    ytUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    startTime: 30,
    endTime: 40,
    playerOptions: {
      width: "500px",
      height: "300px",
      sources: [
        {
          type: "video/mp4",
          src: "https://cdn.theguardian.tv/webM/2015/07/20/150716YesMen_synd_768k_vp8.webm",
        },
      ],
    },
  }),

  computed: {
    videoPlayer() {
      return this.$refs.videoPlayer.player;
    },
  },

  methods: {
    onVideoTimeUpdate(player) {
      //console.log(`${player.cache_.currentTime} / ${player.cache_.duration}`);
      if (player.cache_.currentTime >= this.endTime) {
        player.pause();
        player.play();
      }
    },
    onVideoStartsPlay(player) {
      player.currentTime(this.startTime);
    },
  },

  beforeDestroy() {
    clearInterval(this.jobId);
  },
};
</script>
