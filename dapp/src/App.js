import React from 'react';
import { BrowserRouter as Router, useRoutes } from "react-router-dom";
import Home from "./pages/Home";
import Flights from "./pages/Flights"
import './App.css';

const App = () => {
  let routes = useRoutes([
    { path: "/", element: <Home /> },
    { path: "/flights", element: <Flights /> }
  ]);
  return routes;
};

// export default App;
const AppWrapper = () => {
  return (
    <Router>
      <App />
    </Router>
  );
};

export default AppWrapper;