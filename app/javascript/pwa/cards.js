import { h, render, Component } from 'preact';

export default class Cards extends Component {
  constructor(props) {
    super(props)
    this.state = {
      cards: []
    }
  }

  componentDidMount() {
    let component = this
    fetch('/api/cards', {
      method: 'get',
      headers: {'Content-Type':'application/json','Auth-Token':localStorage.token}
    }).then((response) => {
       if (response.status !== 200) {
         response.json().then(function(data) {
           alert(data.errors)
         })
        return;
      }
      response.json().then(function(data) {
        component.setState({cards: data.cards})
      });
    });
  }

  render() {
    return (
      <main id='app'>
        <section>
          <header>Cards</header>
          <ul>
            { this.state.cards.map((card, i) => {
              return(
                <li>
                  {card.type} {card.pan}
                  <button type='button' onClick={() => this.delete(card.id, i)}>x</button>
                </li>
              )
            })}
        </ul>
        <button type='button' onClick={this.add}>+ Add Card</button>
        </section>
      </main>
    )
  }

  add = () => {
  }

  create = () => {
  }

  delete = (id, index) => {
    let component = this
    let cards = this.state.cards
    cards.splice(index, 1)
    fetch(`/api/cards/${id}`, {
      method: 'delete',
      headers: {'Content-Type':'application/json', 'Auth-Token':localStorage.token}
    }).then((response) => {
       if (response.status !== 200) {
         response.json().then(function(data) {
           alert(data.errors)
         })
        return;
      }
      component.setState({
        cards: cards
      })
    });
  }
}
