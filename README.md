# Minishop

This is an ecommerce marketplace application built using Ruby on Rails as part of the [Full Stack Rails Mastery course](https://learnetto.com/users/hrishio/courses/full-stack-rails-mastery?utm_source=github&utm_medium=minishop) on Learnetto.

# Minishop Practice Setup Guide

This guide provides step-by-step instructions on how to set up and run the Minishop Practice project on your local machine.

## Prerequisites

Before you begin, ensure you have the following installed on your system:

* **macOS:** This guide assumes you are using macOS.
* **Xcode Command Line Tools:** These are necessary for Ruby and Rails. You can install them by running:
    ```bash
    xcode-select --install
    ```
* **Ruby Version Manager (rbenv recommended):** This helps manage different Ruby versions. If you don't have it, you can install it with Homebrew:
    ```bash
    brew update
    brew install rbenv ruby-build
    ```
    After installation, add rbenv to your shell:
    ```bash
    echo 'eval "$(rbenv init - bash)"' >> ~/.bashrc  # For Bash
    echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc   # For Zsh
    source ~/.bashrc
    source ~/.zshrc
    ```
    Restart your terminal or open a new window.
* **Ruby:** This project likely requires a specific Ruby version (see `.ruby-version` file). You can install it using rbenv:
    ```bash
    rbenv install <ruby_version>
    rbenv global <ruby_version>
    ```
    Replace `<ruby_version>` with the version specified in the `.ruby-version` file (e.g., `3.3.4`).
* **Bundler:** This is a dependency manager for Ruby projects. Install it with:
    ```bash
    gem install bundler
    ```
* **PostgreSQL:** This project uses PostgreSQL as its database. If you don't have it, install it with Homebrew:
    ```bash
    brew install postgresql
    brew services start postgresql
    ```

## Setup Instructions

Follow these steps to get the Minishop Practice project running:

1.  **Clone the Repository:**
    ```bash
    git clone <repository_url> minishop_practice
    cd minishop_practice
    ```
    Replace `<repository_url>` with the actual URL of this repository.

2.  **Install Ruby Dependencies:**
    ```bash
    bundle install
    ```
    This command installs all the necessary Ruby gems defined in the `Gemfile`.

3.  **Set up Environment Variables:**
    This project uses environment variables for configuration, likely including API keys for services like Stripe.
    * Create a `.env` file in the root directory of the project:
        ```bash
        touch .env
        ```
    * Open the `.env` file and add the required environment variables. For development with Stripe, you'll need your test keys:
        ```
        STRIPE_SECRET_KEY=sk_test_your_test_secret_key
        STRIPE_PUBLISHABLE_KEY=pk_test_your_test_publishable_key
        # Add any other environment variables here
        ```
        **Note:** Ensure the `dotenv-rails` gem is in your `Gemfile` and you have run `bundle install` for these variables to be loaded.

4.  **Configure PostgreSQL:**
    * **Create the Development Database:**
        ```bash
        psql -U postgres
        CREATE DATABASE minishop_development;
        \q
        ```
        You might need to adjust the username (`postgres`) based on your PostgreSQL setup. You can also create a specific user and grant privileges if needed (see previous instructions).
    * **Update `database.yml`:** Open the `config/database.yml` file and configure the `development` section to match your PostgreSQL setup. Ensure the `database` name is `minishop_development` and provide the correct `username` and `password` if you have set them.

5.  **Run Database Migrations:**
    ```bash
    rails db:migrate
    ```
    This command creates the necessary tables in your PostgreSQL database based on the project's migrations.

6.  **Install and Configure Tailwind CSS:**
    This project uses Tailwind CSS for styling.
    ```bash
    rails tailwindcss:install
    ```
    This command sets up Tailwind CSS in your project.

7.  **Update Layout for Tailwind CSS:**
    Open `app/views/layouts/application.html.erb` and change the `stylesheet_link_tag` for Tailwind CSS to point to the built CSS file (usually `application.css`):
    ```erb
    <%= stylesheet_link_tag "application", "inter-font", "data-turbo-track": "reload" %>
    ```
    Make sure to keep any other stylesheets you are including.

## Running the Application

To start the development server, run:

```bash
rails server