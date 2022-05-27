import React from "react";
import "./Home.css";
import { Link } from "react-router-dom";
import bg from "../images/frontpagebg.jpg";
import logo from "../images/plane_logo_1.svg";
import { Icon, Button, Select, DatePicker, Input, ConnectButton } from "web3uikit";
import { useState } from "react";

const Home = () => {

  const [departureDate, setDepartureDate] = useState(new Date());
  const [departFrom, setDepartFrom] = useState("SFO");
  const [departTo, setDepartTo] = useState("LAX");
  const [travelers, setTravelers] = useState(1);
  const [fClass, setFClass] = useState("Any");

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
          <ConnectButton />
        </div>
      </div>
      <div className="tabContent">
        <div className="searchFields">
          <div className="inputs">
            From
            <Select
              defaultOptionIndex={0}
              onChange={(data) => setDepartFrom(data.label)}
              options={[
                {
                  id: "SFO",
                  label: "SFO",
                }
              ]}
            />
          </div>
          <div className="vl" />
          <div className="inputs">
            To
            <Select
              defaultOptionIndex={0}
              onChange={(data) => setDepartTo(data.label)}
              options={[
                {
                  id: "LAX",
                  label: "LAX",
                }
              ]}
            />
          </div>
          <div className="vl" />
          <div className="inputs">
            Date
            <DatePicker
              id="DepartureDate"
              onChange={(event) => setDepartureDate(event.date)}
            />
          </div>
          <div className="vl" />
          <div className="inputs">
            Class
            <Input
              value={"Any"}
              name="Fclass"
              type="String"
              onChange={(event) => setFClass(event.target.value)}
            />
          </div>
          <div className="vl" />
          <div className="inputs">
            Travelers
            <Input
              value={1}
              name="Travelers"
              type="number"
              onChange={(event) => setTravelers(Number(event.target.value))}
            />
          </div>
          <Link to={"/flights"} state={{
            departFrom: departFrom,
            departTo: departTo,
            departureDate: departureDate,
            fClass: fClass,
            travelers: travelers
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