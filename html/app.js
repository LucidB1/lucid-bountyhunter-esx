const APP = new Vue({
  el: "#app",
  data: {
    show: false,
    maxBountyPerPage: 6,
    currentPage: 1,
    currentPageIndex: 1,

    maxDisplayBountyPerPage: 3,
    currentDisplayBountyPage: 1,
    currentDisplayBountyPageIndex: 1,

    showForm: false,
    player: {},
    selectedBounty: null,
    showDetails: false,
    players: [],
    form: {
      bountyReward: null,
      selectedPlayer: null,
      reason: null,
      filteredName: null,
      filteredDisplayName: null,
    },
    coords: {},
    bounties: [],
  },
  methods: {
    setShow(v, coords, players) {
      this.show = v;
      if (v) {
        this.coords = coords;
        this.players = players;
      } else {
        console.log(v);
        $.post("http://lucid_bountyhunter-esx/close");
      }
    },

    setPlayers(players) {
      console.log("updating 2 2 2, ", players);
      this.players = players;
    },
    setFormShow(v, players) {
      this.show = v;
      this.players = players;
      this.showForm = v;
    },
    setShowDetails(show) {
      console.log(show);
      this.showDetails = show;
    },

    updateBounties(data) {
      this.bounties = [];
      data.forEach((item, index) => {
        this.bounties.push({
          id: item.id,
          reason: item.reason,
          text: item.target_name + " - " + item.bountyReward + "$",
          owner: item.owner,
          playername: item.target_name,
          target: item.target,
          hunters: item.hunters,
          bountyReward: item.bountyReward,
        });
      });
    },
    closeForm() {
      this.showForm = false;
      this.form.bountyReward = null;
      this.form.selectedPlayer = null;
    },
    selectJob() {
      if (this.selectedBounty != null) {
        $.post(
          "http://lucid_bountyhunter-esx/takeBounty",
          JSON.stringify({
            data: this.selectedBounty,
          })
        );
      }
    },

    viewBounty(bounty) {
      this.selectedBounty = bounty;
    },
    sendToBoard() {
      let bountyReward = this.form.bountyReward;
      let player = this.form.selectedPlayer;
      let reason = this.form.reason;
      if (bountyReward > 0 && player != null && reason != null) {
        $.post(
          "http://lucid_bountyhunter-esx/sendBounty",
          JSON.stringify({
            formInputs: {
              bountyReward,
              player,
              reason,
            },
          })
        );
      }
    },
    getPlayerNameByIdentifier(identifier) {
      if (this.players != undefined) {
        let data = this.players.filter((player) => {
          return player.identifier == identifier;
        });

        return (data[0] && data[0].firstname) || "Couldn't find the name";
      }
    },

    pageChanged(direction) {
      if (direction == "LEFT") {
        if (this.currentPage > 1) {
          this.currentPage -= 1;
          this.currentPageIndex = 1;
        }
      } else {
        if (this.currentPage < this.maxPages) {
          this.currentPage += 1;
          this.currentPageIndex = 1;
        }
      }
    },

    pageChangedDisplayBounty(direction) {
      if (direction == "LEFT") {
        if (this.currentDisplayBountyPage > 1) {
          this.currentDisplayBountyPage -= 1;
          this.currentDisplayBountyPageIndex = 1;
        }
      } else {
        if (this.currentDisplayBountyPage < this.maxPagesDisplayBounties) {
          this.currentDisplayBountyPage += 1;
          this.currentDisplayBountyPageIndex = 1;
        }
      }
    },
    closeDetails() {
      $.post("http://lucid_bountyhunter-esx/close");

      this.showDetails = false;
    },
  },

  watch: {
    bountyDisplayPage: function () {
      this.currentDisplayBountyPage = 1;
      this.currentDisplayBountyPageIndex = 1;
    },
  },
  computed: {
    position() {
      return {
        left: this.coords.left * 100 + "%",
        top: this.coords.top * 100 + "%",
      };
    },
    bountyDisplayPage() {
      return this.form.filteredDisplayName;
    },
    maxPages() {
      return Math.ceil(this.bounties.length / this.maxBountyPerPage);
    },
    maxPagesDisplayBounties() {
      return Math.ceil(
        this.getFilteredDisplayBounties.length / this.maxDisplayBountyPerPage
      );
    },

    filteredPlayers() {
      return this.players.filter((player) => {
        if (this.form.filteredName == null) {
          return player;
        } else {
          return player.firstname
            .toLowerCase()
            .startsWith(this.form.filteredName.toLowerCase());
        }
      });
    },
    getFilteredDisplayBounties() {
      return this.bounties.filter((bounty) => {
        if (this.form.filteredDisplayName == null) {
          return bounty;
        } else {
          return this.getPlayerNameByIdentifier(bounty.target)
            .toLowerCase()
            .startsWith(this.form.filteredDisplayName.toLowerCase());
        }
      });
    },
    getPagesBounties() {
      const data = this.bounties.filter((val, index) => {
        if (this.currentPage == 1) {
          return index < this.currentPage * this.maxBountyPerPage;
        } else {
          return (
            index + this.maxBountyPerPage >=
            this.maxBountyPerPage * this.currentPage
          );
        }
      });

      return data;
    },

    getPagesDisplayBounties() {
      const data = this.getFilteredDisplayBounties.filter((val, index) => {
        if (this.currentDisplayBountyPage == 1) {
          return (
            index < this.currentDisplayBountyPage * this.maxDisplayBountyPerPage
          );
        } else {
          console.log(index);
          return (
            index + this.maxDisplayBountyPerPage >=
            this.maxDisplayBountyPerPage * this.currentDisplayBountyPage
          );
        }
      });

      return data;
    },
  },
});

document.onkeydown = (e) => {
  switch (e.keyCode) {
    case 27:
      if (APP.show) {
        APP.setShow(false);
        $.post("http://lucid_bountyhunter-esx/close");
      }
      break;
    default:
      break;
  }
};

window.addEventListener("message", function (event) {
  var item = event.data;
  switch (event.data.action) {
    case "show":
      break;
    case "pressed":
      if (item.pressed == "enter") {
        APP.setFormShow(true, item.players);
      }
      break;

    case "update":
      let form = item.data;
      APP.updateBounties(form);
      break;
    case "displayDetailsPage":
      APP.setShowDetails(item.data);
      break;
    case "updatePlayers":
      console.log("updating ", item.players);
      APP.setPlayers(item.players);
      break;
    default:
      break;
  }

  if (item.show != undefined) {
    APP.setShow(item.show, item.coords, item.players);
  }
});
