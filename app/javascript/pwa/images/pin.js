import { h, render, Component } from 'preact';
import PropTypes from 'prop-types';


const Pin = ({...props }) => {
  const { color, fillColor, onClick, style } = props;
  const pinStyle = {maxWidth: "20px", maxHeight: "20px", position: "absolute", right: "30px", top: "18px", ...style};

  return (
    <svg onClick={onClick} style={pinStyle} xmlns="http://www.w3.org/2000/svg" viewBox="-384 396.7 54.9 82.1">
      <path fill={fillColor} stroke={color} stroke-miterlimit="10" stroke-width="4" d="M-356.5 476.6c.8 0 1.3-.5 1.8-1 5.8-9.4 23.5-39.7 23.5-51.4 0-13.9-11.4-25.3-25.3-25.3s-25.3 11.4-25.3 25.3c0 11.6 17.7 42 23.5 51.4.5.5 1.3 1 1.8 1zm-12.4-52.7c0-6.6 5.3-12.1 12.1-12.1 6.6 0 12.1 5.3 12.1 12.1 0 6.6-5.3 12.1-12.1 12.1-6.8.1-12.1-5.2-12.1-12.1z"/>
    </svg>
  )
};

Pin.propTypes = {
  color: PropTypes.string,
  fillColor: PropTypes.string,
  onClick: PropTypes.func,
  style: PropTypes.obj
};

Pin.defaultProps = {
  color: "#FFF",
  fillColor: "none",
  onClick: () => {},
  style: {}
};

export default Pin;

