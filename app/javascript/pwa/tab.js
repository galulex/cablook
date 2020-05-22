import { h, Component } from 'preact'

export default class Tab extends Component {
  onClick = () => {
    const { label, onClick } = this.props
    onClick(label)
  }

  render() {
    const {
      onClick,
      props: {
        activeTab,
        label,
      },
    } = this

    let className = 'tab__header'

    if (activeTab === label) { className += ' active' }

    return (
      <div
        className={className}
        onClick={onClick}>
          {label}
      </div>
    );
  }
}