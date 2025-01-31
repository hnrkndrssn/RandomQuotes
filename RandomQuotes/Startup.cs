﻿// using System.Collections.Generic;
// using System.IO;
// using System.Linq;
// using Microsoft.AspNetCore.Builder;
// using Microsoft.AspNetCore.Hosting;
// using Microsoft.AspNetCore.HttpOverrides;
// using Microsoft.Extensions.Configuration;
// using Microsoft.Extensions.DependencyInjection;
// using RandomQuotes.Models;

// namespace RandomQuotes
// {
//     public class Startup
//     {
//         public Startup(IConfiguration configuration)
//         {
//             Configuration = configuration;
//         }

//         public IConfiguration Configuration { get; }

//         // This method gets called by the runtime. Use this method to add services to the container.
//         public void ConfigureServices(IServiceCollection services)
//         {
//             services.AddMvc(option => option.EnableEndpointRouting = false);
//             services.Configure<AppSettings>(Configuration.GetSection("AppSettings"));
//         }

//         // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
//         public void Configure(IApplicationBuilder app, IHostingEnvironment env)
//         {
//             if (env.IsDevelopment())
//             {
//                 app.UseDeveloperExceptionPage();
//             }
//             else
//             {
//                 app.UseExceptionHandler("/Home/Error");
//             }

//             app.UseStaticFiles();

//             app.UseMvc(routes =>
//             {
//                 routes.MapRoute(
//                     name: "default",
//                     template: "{controller=Home}/{action=Index}/{id?}");
//             });

//             app.UseForwardedHeaders(new ForwardedHeadersOptions
//             {
//                 ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto
//             });

//             Quote.Initialize();
//         }
//     }
// }