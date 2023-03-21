import { h, render, Component } from 'preact';
import axios from 'axios';

export default class Widget extends Component {
  componentDidMount() {
    this.addCard()
  }

  render() {
    return(<div></div>)
  }

  addCard = () => {
    axios.post('cards').then(({data}) => {
      window.location.href = data.link
    }).catch((error) => {
      if (error.response) alert(error.response.data.errors)
    })
  }
}
