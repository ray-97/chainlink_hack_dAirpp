import React from "react";
import "./Home.css";
import { Link } from "react-router-dom";
import bg from "../images/frontpagebg.jpg";
import logo from "../images/plane_logo_1.svg";
import { Icon, Button } from "web3uikit"; // , Icon, Select, DatePicker, Input, ConnectButton
// import { useState } from "react";

const Home = () => {


  return (
    <>
      <div className="container" style={{ backgroundImage: `url(${bg})` }}>
        <div className="containerGradinet"></div>
      </div>
      <div className="topBanner">
        <div>
          <img className="logo" src={logo} alt="logo"></img>
        </div>
        <div className="tabs">
          <div className="selected">One Way</div>
          <div>Round Trip</div>
          <div>Multi-City</div>
        </div>
        <div className="lrContainers">
          {/* <ConnectButton /> */}
        </div>
      </div>
      <div className="tabContent">
        <div className="searchFields">
          <div className="inputs">
            Location
          </div>
          <div className="vl" />
          <div className="inputs">
            Departure
          </div>
          <div className="vl" />
          <div className="inputs">
            Travelers
          </div>
          <Link to={"/flights"} state={{
            // destination: destination,
            // checkIn: checkIn,
            // checkOut: checkOut,
            // guests: guests
          }}>
            <div className="searchButton">
              <Icon fill="#ffffff" size={24} svg="search" />
            </div>
          </Link>
        </div>
      </div>
      <div className="randomLocation">
        <div className="title">Feeling Adventurous?</div>
        <div className="text">
          Let us decide and discover new places to stay, live, work or just
          relax.
        </div>
        <Button
          text="Explore A Location"
        />
      </div>
    </>
  );
};

export default Home;