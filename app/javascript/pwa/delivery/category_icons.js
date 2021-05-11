import { h } from 'preact'
import Burger from '../images/categories/burger.svg'
import Calzone from '../images/categories/calzone.svg'
import ColdDesserts from '../images/categories/cold_desserts.svg'
import ColdDrinks from '../images/categories/cold_drinks.svg'
import Desserts from '../images/categories/desserts.svg'
import Fries from '../images/categories/fries.svg'
import HappyMeal from '../images/categories/happy_meal.svg'
import HotDrinks from '../images/categories/hot_drinks.svg'
import Meat from '../images/categories/meat.svg'
import Menus from '../images/categories/menus.svg'
import Pizza from '../images/categories/pizza.svg'
import Rolls from '../images/categories/rolls.svg'
import Salads from '../images/categories/salads.svg'
import Sandwiches from '../images/categories/sandwiches.svg'
import Sauces from '../images/categories/sauces.svg'
import Snacks from '../images/categories/snacks.svg'
import Soups from '../images/categories/soups.svg'
import Veggies from '../images/categories/veggies.svg'
import DefaultIcon from '../images/categories/menus.svg'


export default function CategoryIcon(props) {
  let Icons = {
    burger: Burger,
    calzone: Calzone,
    cold_desserts: ColdDesserts,
    cold_drinks: ColdDrinks,
    desserts: Desserts,
    fries: Fries,
    happy_meal: HappyMeal,
    hot_drinks: HotDrinks,
    meat: Meat,
    menus: Menus,
    pizza: Pizza,
    rolls: Rolls,
    salads: Salads,
    sandwiches: Sandwiches,
    sauces: Sauces,
    snacks: Snacks,
    soups: Soups,
    veggies: Veggies
  }[props.icon] || DefaultIcon

  return <Icons />
}
