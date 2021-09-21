<template>
  <v-container>
    <v-row>
      <video-player
        class="video-player-box"
        :options="playerOptions"
        @playing="onVideoPlaying($event)"
        @timeupdate="onVideoTimeUpdate($event)"
        :playsinline="true"
      >
      </video-player>
    </v-row>
  </v-container>
</template>

<script>
export default {
  name: "HelloWorld",

  data: () => ({
    playerOptions: {
      sources: [
        {
          type: "video/mp4",
          src: "https://cdn.theguardian.tv/webM/2015/07/20/150716YesMen_synd_768k_vp8.webm",
        },
      ],
    },
  }),

  methods: {
    onVideoPlaying(event) {
      console.log(event);
    },
    onVideoTimeUpdate(event) {
      console.log("time", event);
    },
  },
};
</script>
